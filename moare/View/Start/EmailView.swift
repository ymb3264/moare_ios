//
//  EmailView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct EmailView: View {
    @EnvironmentObject var joinVM: JoinViewModel
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Text(StringResources.emailTitle)
                .font(.title2)
            
            Text(StringResources.emailMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if joinVM.showErrorText || joinVM.networkError {
                Text(joinVM.showErrorText ? StringResources.emailValidationError : joinVM.networkErrorText)
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            
            StartViewTextField(
                placeholder: StringResources.emailPlaceholder,
                text: $joinVM.account.userID
            )
            .focused($isFocused)
            .keyboardType(.emailAddress)
            .onChange(of: joinVM.account.userID) { newValue in
                joinVM.checkEmail()
            }
            
            NavigationLink(
                isActive: $joinVM.goToAuth,
                destination: { AuthView() }
            ) {
                Button(action: {
                    joinVM.getEmailCode(resend: false)
                }) {
                    StartViewButton(enabled: joinVM.emailBtn, loading: $joinVM.loading)
                }
            }
            .disabled(!joinVM.emailBtn)
            .onTapGesture {
                joinVM.showErrorText = !joinVM.emailBtn
            }
            
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
