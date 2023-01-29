//
//  LoginView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct LoginView: View {
    enum Field: Hashable {
        case userID, password
    }
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var loginVM: LoginViewModel
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        let loginBtn = !loginVM.account.userID.isEmpty && !loginVM.account.password.isEmpty
        
        VStack(spacing: 12) {
            Spacer()
            
            if loginVM.showErrorText2 {
                Text(StringResources.loginError)
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            
            StartViewTextField(
                placeholder: StringResources.emailPlaceholder,
                text: $loginVM.account.userID
            )
            .focused($focusedField, equals: .userID)
            .submitLabel(.next)
            .keyboardType(.emailAddress)
            
            PwdTextField(
                placeholder: StringResources.passwordPlaceholder,
                text: $loginVM.account.password
            )
            .focused($focusedField, equals: .password)
            .onChange(of: loginVM.account.password) { _ in
                    loginVM.showErrorText2 = false
                }
            
            ZStack {
                Button(action: {
                    loginVM.login() {
                        focusedField = nil
                    }
                }) {
                    StartViewButton(enabled: loginBtn, loading: $loginVM.loginLoading)
                }
                .disabled(!loginBtn)
                .onTapGesture {
                    loginVM.showErrorText1 = !loginVM.isEmailValid
                }

                HStack {
                    Spacer()
                    NavigationLink(
                        destination: { EmailForNewPwdView() }
                    ) {
                        Text(StringResources.forgotPassword)
                            .font(.caption)
                            .foregroundColor(Color("moare"))
                            .padding(.trailing)
                    }
                }
            }
            
            Spacer()
                .frame(maxHeight: UIScreen.main.bounds.height / 2)
        }
        .offset(x: 0, y: 49.5)
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .userID
            }
        }
        .onSubmit {
            switch focusedField {
            case .userID:
                focusedField = .password
            case .password: focusedField = nil
            default: focusedField = nil
            }
        }
    }
}
