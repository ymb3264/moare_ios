//
//  JoinSportSelectView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct JoinSportSelectView: View {
    @EnvironmentObject var joinVM: JoinViewModel
    @StateObject var sportSelectVM = SportSelectViewModel()
    
    @State var defaultLoading = false
    @State var goToTermsAgree = false
    @State var alert = false
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible())
    ]

    var body: some View {
        
        VStack {
            Text(StringResources.sportSelectTitle)
                .font(.title2)
                .padding(.bottom, 5)
            
            Text(StringResources.sportSelectMessage)
                .font(.body)
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                .padding(.bottom, 5)
                .multilineTextAlignment(.center)
            
            SearchBarView(placeholder: StringResources.search, text: $sportSelectVM.query)
                .onChange(of: sportSelectVM.query) { query in
                    sportSelectVM.searchSport(query: query)
                }
            
            if sportSelectVM.loading {
                ProgressView()
            }

            if !sportSelectVM.selectedSport.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(sportSelectVM.selectedSport, id: \.self) { sport in
                            Text("\(sport)")
                                .font(.body)
                                .foregroundColor(Color("moare"))
                                .padding(.leading, 10)
                        }
                        Spacer()
                    }
                    .padding(.leading, 10)
                }
            }
            
            ScrollView {
                SportHashtagListView(
                    sportSelectVM: sportSelectVM,
                    action1: { key in
                        sportSelectVM.selectSport(key: key)
                        joinVM.account.sportHashtag = sportSelectVM.selectedSport
                    }
                ) { key in
                    sportSelectVM.newSelectSport(key: key)
                    joinVM.account.sportHashtag = sportSelectVM.selectedSport
                }
            }
            
            NavigationLink(
                isActive: $goToTermsAgree,
                destination: { TermsAgreeView() }
            ) {
                Button(action: {
                    if joinVM.account.sportHashtag.isEmpty {
                        alert = true
                    } else {
                        goToTermsAgree = true
                    }
                }) {
                    StartViewButton(enabled: true, loading: $defaultLoading)
                }
            }
            
            .alert(isPresented: $alert) {
                Alert(
                    title: Text(StringResources.sportSelectTitle),
                    message: Text(StringResources.sportSelectAlertMessage).multilineTextAlignment(.center) as? Text,
                    primaryButton: .destructive(Text(StringResources.cancel)),
                    secondaryButton: .cancel(Text(StringResources.confirm), action: {
                        goToTermsAgree = true
                    })
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
    }
}
