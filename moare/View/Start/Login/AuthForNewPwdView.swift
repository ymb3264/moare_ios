//
//  AuthForNewPwdView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct AuthForNewPwd: View {
    @EnvironmentObject var loginVM: LoginViewModel
    
    @State var defaultLoading = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text(StringResources.authCodeTitle)
                .font(.title2)
            
            Text(loginVM.userID + StringResources.authCodeMessage)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            
            Button(action: {
                loginVM.getEmailCode(resend: true)
            }) {
                if loginVM.loading {
                    ProgressView()
                        .tint(Color("moare"))
                } else {
                    Text(StringResources.resendAuthCode)
                        .font(.subheadline)
                }
            }
            .padding(.top, -8)
            
            if loginVM.showErrorText1 || loginVM.networkError {
                Text(loginVM.showErrorText1 ? StringResources.wrongAuthCodeError : StringResources.failedToSendAuthCode)
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            
            StartViewTextField(placeholder: StringResources.authCodePlaceholder, text: $loginVM.clientCode)
            
            NavigationLink(
                isActive: $loginVM.goToPwd,
                destination: { NewPwdView() }
            ) {
                Button(action: {
                    loginVM.checkCode()
                }) {
                    StartViewButton(enabled: !loginVM.clientCode.isEmpty, loading: $defaultLoading)
                }
            }
            .disabled(loginVM.clientCode.isEmpty)

            Spacer()
                .frame(maxHeight: UIScreen.main.bounds.height / 2)
        }
        .offset(x: 0, y: 49.5)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .ignoresSafeArea()
    }
}
