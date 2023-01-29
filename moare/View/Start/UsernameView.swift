//
//  UsernameView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct UsernameView: View {
    @EnvironmentObject var joinVM: JoinViewModel
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text(StringResources.usernameTitle)
                .font(.title2)
            
            if joinVM.showErrorText || joinVM.showErrorText2 || joinVM.networkError {
                Text(joinVM.showErrorText ? StringResources.usernameValidationError : StringResources.existingUsernameError)
                .font(.subheadline)
                .foregroundColor(.red)
            }
            
            UsernameTextField(
                placeholder: "사용자 이름",
                text: $joinVM.account.username,
                loading: $joinVM.usernameLoading
            )
            .focused($isFocused)
            .onChange(of: joinVM.account.username) { i in
                joinVM.checkUsername()
            }
            
            NavigationLink(
                isActive: $joinVM.goToSportSelect,
                destination: { JoinSportSelectView() }
            ) {
                Button(action: { joinVM.usernameBtnAction() }) {
                    StartViewButton(enabled: joinVM.usernameBtn, loading: $joinVM.loading)
                }
            }
            .disabled(!joinVM.usernameBtn)
            
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
