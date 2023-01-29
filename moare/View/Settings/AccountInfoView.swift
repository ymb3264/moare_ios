//
//  AccountInfoView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct AccountInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var profileVM: MyProfileViewModel
    
    var body: some View {
        ZStack {
            VStack {
                HStack(alignment: .top) {
                    Text(StringResources.emailPlaceholder)
                        .font(.body)
                    
                    VStack(alignment: .leading) {
                        Text(verbatim: profileVM.myProfile.userID!)
                            .font(.subheadline)
                        
                        Divider()
                    }
                    .padding(.leading, 4)
                }
                
                Button {
                    profileVM.deleteProfile { presentationMode.wrappedValue.dismiss() }
                } label: {
                    Text(profileVM.myProfile.isTeam ? StringResources.deleteTeamProfileButton : StringResources.deleteAccountButton)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .navigationTitle(Text(StringResources.accountInfoNavigationTitle))
            .padding(.horizontal)
            
            if profileVM.loading {
                ProgressView()
            }
        }
    }
}
