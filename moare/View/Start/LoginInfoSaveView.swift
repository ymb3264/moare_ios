//
//  LoginInfoSaveView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct LoginInfoSaveView: View {
    @EnvironmentObject var joinVM: JoinViewModel
    
    @State var defaultLoading = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text(StringResources.loginInfoSaveTitle)
                .font(.title2)
            
            Text(joinVM.account.username + StringResources.loginInfoSaveMessage)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            
            HStack {
                Rectangle()
                    .frame(height: 75)
                    .opacity(0)
                
                ZStack {
                    NavigationLink(
                        isActive: $joinVM.goToSplash,
                        destination: { JoinSplashView() }
                    ) {
                        Button(action: {
                            joinVM.join(saveLoginInfo: true)
                        }) {
                            StartViewButton(enabled: true, loading: $defaultLoading)
                        }
                    }
                   
                    Text(StringResources.save)
                        .font(.subheadline)
                        .foregroundColor(Color("moare"))
                }
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(height: 75)
                        .opacity(0)
                    
                    Button(action: { joinVM.join(saveLoginInfo: false) }) {
                        Text(StringResources.saveLater)
                            .font(.subheadline)
                    }
                    .foregroundColor(Color("moare"))
                    .padding(.leading)
                }
                
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
