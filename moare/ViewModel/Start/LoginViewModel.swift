//
//  LoginViewModel.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import KeychainAccess
import SwiftUI

class LoginViewModel: ObservableObject {
    private let api = LoginAPI()
    
    @Published var account = LoginAccount(userID: "", password: "")
    @Published var userID = ""
    @Published var pwd = ""
    @Published var pwdForCheck = ""
    @Published var clientCode = ""
    
    @Published var isEmailValid = false
    @Published var showErrorText1 = false
    @Published var showErrorText2 = false
    @Published var networkError = false
    @Published var networkErrorText = ""
    
    @Published var loginBtn = false
    @Published var emailBtn = false
    @Published var pwdBtn = false
    
    @Published var goToLogin = false
    @Published var goToAuth = false
    @Published var goToPwd = false
    
    @Published var loading = false
    @Published var loginLoading = false
    @Published var meLoading = false
    
    private var responseForNewPwd = ResponseForNewPwd(createdAt: "", serverCode: 0)
    
    @MainActor init() {
        loginBtn = isEmailValid && !account.password.isEmpty
        
        guard let accessToken = try! Keychain().get("AccessToken") else { return }
        guard let refreshToken = try! Keychain().get("RefreshToken") else { return }
        
        self.me(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    @MainActor func login(completion: @escaping () -> ()) {
        self.loginLoading = true
        self.showErrorText2 = false
        Task {
            do {
                let response = try await api.login(account: account)
                try! Keychain().set(response.accessToken, key: "AccessToken")
                try! Keychain().set(response.refreshToken, key: "RefreshToken")
                UserDefaults.standard.set(response.username, forKey: "username")
                UserDefaults.standard.set(response.userID, forKey: "userID")
                
                completion()
                self.loginLoading = false
                AppState.shared.showMain = true
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError.error {
                    case .requestError:
                        self.loginLoading = false
                        self.showErrorText2 = true
                    case .serverError:
                        self.loginLoading = false
                        self.showErrorText2 = true
                    default:
                        self.loginLoading = false
                        self.showErrorText2 = true
                    }
                } else {
                    self.loginLoading = false
                    self.showErrorText2 = true
                    print("\(error)")
                }
                
            }
        }
    }
    
    @MainActor func me(accessToken: String, refreshToken: String) {
        self.meLoading = true
        Task {
            do {
                let response = try await api.me(accessToken: accessToken, refreshToken: refreshToken)
                try! Keychain().set(response.accessToken, key: "AccessToken")
                try! Keychain().set(response.refreshToken, key: "RefreshToken")
                UserDefaults.standard.set(response.username, forKey: "username")
                UserDefaults.standard.set(response.userID, forKey: "userID")
                
                self.meLoading = false
                AppState.shared.showMain = true
            } catch {
                // nothing to do
                self.meLoading = false
                print("\(error)")
            }
        }
    }
    
    @MainActor func getEmailCode(resend: Bool) {
        self.loading = true
        Task {
            do {
                let response = try await api.getEmailCode(email: userID)
                
                self.responseForNewPwd.createdAt = response.createdAt
                self.responseForNewPwd.serverCode = response.serverCode
                
                self.resetError()
                self.loading = false
                if !resend { self.goToAuth = true }
            } catch APIError.requestError(let response) {
                if response.message == "User not found" {
                    self.loading = false
                    self.networkError = true
                    self.networkErrorText = "해당 이메일로 가입된 계정이 존재하지 않습니다"
                }
            }
        }
    }
    
    @MainActor func setNewPwd() {
        self.loading = true
        Task {
            do {
                let obj = NewPwdObj(userID: userID, createdAt: responseForNewPwd.createdAt, password: pwd)
                try await api.setNewPwd(obj: obj)
                
                self.loading = false
                self.goToLogin = false
            } catch {
                self.loading = false
                print("\(error)")
            }
        }
    }
    
    func checkEmail() {
        self.networkError = false
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        emailBtn = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: userID)
        if emailBtn { showErrorText1 = false }
    }
    
    func checkCode() {
        self.showErrorText1 = false
        if clientCode == String(responseForNewPwd.serverCode) {
            self.resetError()
            goToPwd = true
        } else {
            showErrorText1 = true
        }
    }
    
    func checkPwdRegex() {
        let pwdRegex1 = "(?=.*[a-zA-Z])(?=.*[0-9]).{8,20}"
        let pwdRegex2 = "(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"
        let pwdRegex3 = "(?=.*[a-zA-Z])(?=.*[!@#$%^&*()_+=-]).{8,20}"
        let pwdRegex4 = "(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"
        
        let isValid = NSPredicate(format: "SELF MATCHES %@", pwdRegex1).evaluate(with: pwd) ||
                      NSPredicate(format: "SELF MATCHES %@", pwdRegex2).evaluate(with: pwd) ||
                      NSPredicate(format: "SELF MATCHES %@", pwdRegex3).evaluate(with: pwd) ||
                      NSPredicate(format: "SELF MATCHES %@", pwdRegex4).evaluate(with: pwd)
        
        self.showErrorText1 = !isValid
    }
    
    func checkSecondPwd() {
        self.showErrorText2 = self.pwd != self.pwdForCheck
        self.pwdBtn = !self.showErrorText2
    }
    
    func resetError() {
        self.showErrorText1 = false
        self.showErrorText2 = false
    }
}
