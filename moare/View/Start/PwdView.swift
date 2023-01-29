//
//  PwdView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct PwdView: View {
    enum Field: Hashable {
        case password, passwordForCheck
    }
    
    @EnvironmentObject var joinVM: JoinViewModel
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text(StringResources.passwordTitle)
                .font(.title2)
            
            if joinVM.showErrorText || joinVM.showErrorText2 {
                Text(joinVM.showErrorText ? StringResources.passwordValidationError : StringResources.wrongPasswordForCheck)
                .font(.subheadline)
                .foregroundColor(.red)
            }
            
            PwdTextField(
                placeholder: StringResources.passwordPlaceholder,
                text: $joinVM.account.password
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.next)
            .onChange(of: joinVM.account.password) { _ in
                joinVM.checkPwdRegex()
            }
            
            PwdTextField(
                placeholder: StringResources.passwordForCheckPlaceholder,
                text: $joinVM.pwdForCheck
            )
            .focused($focusedField, equals: .passwordForCheck)
            .onChange(of: joinVM.pwdForCheck) { _ in
                if !joinVM.showErrorText {
                    joinVM.checkSecondPwd()
                }
            }
            
            
            NavigationLink(
                isActive: $joinVM.goToUsername,
                destination: { UsernameView() }
            ) {
                Button(action: { joinVM.pwdBtnAction() }) {
                    StartViewButton(enabled: joinVM.pwdBtn, loading: $joinVM.loading)
                }
            }
            .disabled(!joinVM.pwdBtn)
            
            Spacer()
                .frame(maxHeight: UIScreen.main.bounds.height / 2)
        }
        .offset(x: 0, y: 49.5)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .password
            }
        }
        .onSubmit {
            switch focusedField {
            case .password:
                focusedField = .passwordForCheck
            case .passwordForCheck: focusedField = nil
            default: focusedField = nil
            }
        }
    }
}
