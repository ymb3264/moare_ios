//
//  SettingsView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            NavigationLink(
                destination: { AccountInfoView() }
            ) {
                Text(StringResources.account)
                    .font(.body)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }

            NavigationLink(
                destination: { InfoView() }
            ) {
                Text(StringResources.info)
                    .font(.body)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            NavigationLink(
                destination: { ContactView() }
            ) {
                Text(StringResources.questions)
                    .font(.body)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            Button(action: { AppState.shared.logout() }) {
                Text(StringResources.logoutButton)
                    .font(.subheadline)
                    .foregroundColor(Color("moare"))
                    .padding(.top)
                
                Spacer()
            }
            Spacer()
        }
        .foregroundColor(.primary)
        .padding(.horizontal)
        .navigationTitle(Text(StringResources.settingsNavigationTitle))
    }
}
