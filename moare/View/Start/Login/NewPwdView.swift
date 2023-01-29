//
//  NewPwdView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct NewPwdView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text(StringResources.passwordTitle)
                .font(.title2)
            
            if loginVM.showErrorText1 || loginVM.showErrorText2 {
                Text(loginVM.showErrorText1 ? StringResources.passwordValidationError : StringResources.wrongPasswordForCheck)
                .font(.subheadline)
                .foregroundColor(.red)
            }
            
            PwdTextField(
                placeholder: StringResources.passwordPlaceholder,
                text: $loginVM.pwd
            ).onChange(of: loginVM.pwd) { _ in
                loginVM.checkPwdRegex()
            }
            PwdTextField(
                placeholder: StringResources.passwordForCheckPlaceholder,
                text: $loginVM.pwdForCheck
            ).onChange(of: loginVM.pwdForCheck) { _ in
                if !loginVM.showErrorText1 {
                    loginVM.checkSecondPwd()
                }
            }
            
            Button(action: { loginVM.setNewPwd() }) {
                StartViewButton(enabled: loginVM.pwdBtn, loading: $loginVM.loading)
            }
            .disabled(!loginVM.pwdBtn)
            
            Spacer()
                .frame(maxHeight: UIScreen.main.bounds.height / 2)
        }
        .offset(x: 0, y: 49.5)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}
