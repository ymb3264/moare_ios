//
//  JoinViewModel.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import Foundation
import Combine
import KeychainAccess
import StreamChat
import StreamChatSwiftUI

class JoinViewModel: ObservableObject {
    private let api = JoinAPI()
    
    @Published var account = JoinAccount(userID: "", createdAt: "", password: "", username: "", allTermsAgreed: false)
    @Published var clientCode = ""
    @Published var pwdForCheck = ""
    
    @Published var showErrorText = false
    @Published var showErrorText2 = false
    @Published var networkError = false
    @Published var networkErrorText = ""
    
    @Published var goToAuth = false
    @Published var goToPwd = false
    @Published var goToUsername = false
    @Published var goToSportSelect = false
    @Published var goToSplash = false

    @Published var networkErrorAlert = false
    
    @Published var joinSuccess = false
    
    @Published var loading = false
    @Published var usernameLoading = false
    
    var emailBtn = false
    var pwdBtn = false
    var usernameBtn = false
    
    private var serverCode = ""
    
    @Injected(\.chatClient) var chatClient
    
    // api
    @MainActor func getEmailCode(resend: Bool) {
        self.loading = true
        Task {
            do {
                self.serverCode = try await String(api.getEmailCode(email: account.userID).serverCode)
                self.resetError()
                self.loading = false
                if !resend { self.goToAuth = true }
            } catch APIError.requestError(let response) {
                if response.message == "email already exists" {
                    self.loading = false
                    showNetworkError()
                    networkErrorText = "해당 이메일로 가입된 계정이 이미 존재합니다."
                }
            }
        }
    }
    
    @MainActor func checkUsername2() {
        self.usernameLoading = true
        Task {
            do {
                let response = try await api.checkUsername(username: account.username)
                
                self.usernameLoading = false
                
                if response.message == "available" {
                    self.usernameBtn = true
                } else {
                    self.showErrorText2 = true
                    self.usernameBtn = false
                }
            } catch {
                self.usernameLoading = false
                if let networkError = error as? NetworkError {
                    switch networkError.error {
                    case .requestError:
                        showNetworkError()
                    case .serverError:
                        showNetworkError()
                    default:
                        showNetworkError()
                    }
                } else {
                    showNetworkError()
                    print("\(error)")
                }
            }
        }
    }
    
    @MainActor func join(saveLoginInfo: Bool) {
        goToSplash = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
        account.createdAt = dateFormatter.string(from: Date())
        
        Task {
            do {
                let response = try await api.join(account: account)
                
                self.joinSuccess = true
                
                if saveLoginInfo {
                    try Keychain().set(response.accessToken, key: "AccessToken")
                    try Keychain().set(response.refreshToken, key: "RefreshToken")
                }
                UserDefaults.standard.set(response.username, forKey: "username")
                UserDefaults.standard.set(response.userID, forKey: "userID")
            } catch {
                print("\(error)")
                
                if let networkError = error as? NetworkError {
                    switch networkError.error {
                    case .requestError:
                        self.networkErrorAlert = true
                    case .serverError:
                        self.networkErrorAlert = true
                    default:
                        self.networkErrorAlert = true
                    }
                } else {
                    self.networkErrorAlert = true
                    print("\(error)")
                }
            }
        }
    }
    
    // internal
    func checkEmail() {
        self.networkError = false
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        emailBtn = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: account.userID)
        if emailBtn { showErrorText = false }
    }
    
    func checkCode() {
        if clientCode == serverCode {
            self.resetError()
            goToPwd = true
        } else {
            showErrorText = true
        }
    }
    
    func checkPwdRegex() {
        let pwdRegex1 = "(?=.*[a-zA-Z])(?=.*[0-9]).{8,20}"
        let pwdRegex2 = "(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"
        let pwdRegex3 = "(?=.*[a-zA-Z])(?=.*[!@#$%^&*()_+=-]).{8,20}"
        let pwdRegex4 = "(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"
        
        let isValid = NSPredicate(format: "SELF MATCHES %@", pwdRegex1).evaluate(with: account.password) ||
                      NSPredicate(format: "SELF MATCHES %@", pwdRegex2).evaluate(with: account.password) ||
                      NSPredicate(format: "SELF MATCHES %@", pwdRegex3).evaluate(with: account.password) ||
                      NSPredicate(format: "SELF MATCHES %@", pwdRegex4).evaluate(with: account.password)
        
        self.showErrorText = !isValid
    }
    
    func checkSecondPwd() {
        self.showErrorText2 = self.account.password != self.pwdForCheck
        self.pwdBtn = !self.showErrorText2
    }
    
    @MainActor func checkUsername() {
        usernameBtn = false
        showErrorText2 = false
        
        let usernameRegex = "[A-Za-z_.[0-9]]{1,30}"
        showErrorText = !NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: account.username)
        
        if (!showErrorText) {
            checkUsername2()
        }
    }
    
    func pwdBtnAction() {
        self.resetError()
        self.goToUsername = true
    }
    
    func usernameBtnAction() {
        self.resetError()
        self.goToSportSelect = true
    }
    
    func showNetworkError() {
        self.showErrorText = false
        self.showErrorText2 = false
        self.networkError = true
    }
    
    func resetError() {
        self.showErrorText = false
        self.showErrorText2 = false
        self.networkError = false
    }
}
