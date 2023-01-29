//
//  AuthView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var joinVM: JoinViewModel
    
    @State var defaultLoading = false
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text(StringResources.authCodeTitle)
                .font(.title2)
            
            Text(joinVM.account.userID + StringResources.authCodeMessage)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            
            Button(action: {
                joinVM.getEmailCode(resend: true)
            }) {
                if joinVM.loading {
                    ProgressView()
                        .tint(Color("moare"))
                } else {
                    Text(StringResources.resendAuthCode)
                        .font(.subheadline)
                }
            }
            .padding(.top, -8)
            
            if joinVM.showErrorText || joinVM.networkError {
                Text(joinVM.showErrorText ? StringResources.wrongAuthCodeError : StringResources.failedToSendAuthCode)
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            
            StartViewTextField(
                placeholder: StringResources.authCodePlaceholder,
                text: $joinVM.clientCode
            )
            .focused($isFocused)
            
            NavigationLink(
                isActive: $joinVM.goToPwd,
                destination: { PwdView() }
            ) {
                Button(action: {
                    joinVM.checkCode()
                }) {
                    StartViewButton(enabled: !joinVM.clientCode.isEmpty, loading: $defaultLoading)
                }
            }
            .disabled(joinVM.clientCode.isEmpty)

            Spacer()
                .frame(maxHeight: UIScreen.main.bounds.height / 2)
        }
        .offset(x: 0, y: 49.5)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
}
