//
//  EmailForNewPwdView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct EmailForNewPwdView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Text(StringResources.emailTitle)
                .font(.title2)
            
            Text(StringResources.emailForNewPwdMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                
            
            if loginVM.showErrorText1 || loginVM.networkError {
                Text(loginVM.showErrorText1 ? StringResources.emailValidationError : loginVM.networkErrorText)
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            
            StartViewTextField(
                placeholder: StringResources.emailPlaceholder,
                text: $loginVM.userID
            ).keyboardType(.emailAddress)
                .onChange(of: loginVM.userID) { _ in
                    loginVM.checkEmail()
                }
            
            NavigationLink(
                isActive: $loginVM.goToAuth,
                destination: { AuthForNewPwd() }
            ) {
                Button(action: {
                    loginVM.getEmailCode(resend: false)
                }) {
                    StartViewButton(enabled: loginVM.emailBtn, loading: $loginVM.loading)
                }
            }
            .disabled(!loginVM.emailBtn)
            .onTapGesture {
                loginVM.showErrorText1 = !loginVM.emailBtn
            }
            
            Spacer()
                .frame(maxHeight: UIScreen.main.bounds.height / 2)
        }
        .offset(x: 0, y: 49.5)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .ignoresSafeArea()
    }
}
