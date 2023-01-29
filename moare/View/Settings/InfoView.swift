//
//  InfoView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        VStack {
            NavigationLink(destination: {
                InfoDetailView(url: StringResources.tosUrl, title: StringResources.tos)
            }) {
                Text(StringResources.tos)
                    .font(.body)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            
            NavigationLink(destination: {
                InfoDetailView(url: StringResources.privacyPolicyUrl, title: StringResources.privacyPolicy)
            }) {
                Text(StringResources.privacyPolicy)
                    .font(.body)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            NavigationLink(destination: {
                InfoDetailView(url: StringResources.locationTosUrl, title: StringResources.locationTos)
            }) {
                Text(StringResources.locationTos)
                    .font(.body)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            Spacer()
        }
        .foregroundColor(.primary)
        .padding(.horizontal)
        .navigationTitle(Text(StringResources.infoNavigationTitle))
    }
}
