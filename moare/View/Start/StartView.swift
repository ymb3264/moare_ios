//
//  StartView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct StartView: View {
    @ObservedObject var joinVM = JoinViewModel()
    @ObservedObject var loginVM = LoginViewModel()
    
    var body: some View {
        if loginVM.meLoading {
            ProgressView()
                .tint(Color("moare"))
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                .ignoresSafeArea()
                .onOpenURL { url in
                    if let yearAndMonth = url.yearAndMonth,
                       let postCreatedAt = url.postCreatedAt {
                        AppState.shared.yearAndMonth = yearAndMonth
                        AppState.shared.postCreatedAt = postCreatedAt
                        AppState.shared.isDeepLinkActive = true
                    }
                }
        } else {
            NavigationView {
                VStack(spacing: 8) {
                    NavigationLink(
                        isActive: $loginVM.goToLogin,
                        destination: { LoginView() }
                    ) {
                        Text(StringResources.login)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Rectangle()
                            .fill(Color("moare"))
                            .frame(height: 1)
                        
                        Circle()
                            .stroke(Color("moare"))
                            .frame(width: 75, height: 75)
                        
                        
                        Rectangle()
                            .fill(Color("moare"))
                            .frame(height: 1)
                    }
                    
                    NavigationLink(
                        destination: EmailView()
                    ) {
                        Text(StringResources.join)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                .navigationTitle("")
                .ignoresSafeArea()
            }
            .environmentObject(loginVM)
            .environmentObject(joinVM)
            .accentColor(Color("moare"))
            .navigationViewStyle(.stack)
        }
    }
}
