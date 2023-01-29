//
//  PostSearchView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct PostSearchView: View {
    @Binding var goMessageView: Bool
    @Binding var messageTarget: String
    @Binding var myProfile: Profile
    
    @StateObject var searchVM = SearchViewModel()
    
    @StateObject var appState = AppState.shared
    
    var body: some View {
        VStack {
            HStack {
                SearchBar(text: $searchVM.query, placeholder: StringResources.search)
                    .onChange(of: searchVM.query) { _ in
                        searchVM.search()
                    }
                
                Button(StringResources.cancel) {
                    appState.postSearchBar = false
                }
                .padding(.trailing, 12)
            }
            
            ScrollView {
                VStack(spacing: 15) {
                    if searchVM.loading {
                        ProgressView()
                    } else {
                        ForEach(searchVM.searchList, id: \.self) { result in
                            if result.starts(with: "#") {
                                Button(action: {
                                }) {
                                    HStack {
                                        Text(result)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .padding(.leading, 10)
                                        
                                        Spacer()
                                    }
                                }
                            } else {
                                NavigationLink(
    //                                isActive: $appState.postRootActive,
                                    destination: {
                                        NavigationLazyView(
                                            UserProfileView(
                                                profileVM: UserProfileViewModel(username: result),
                                                myProfile: $myProfile,
                                                goMessageView: $goMessageView,
                                                messageTarget: $messageTarget
                                            )
                                        )
                                    }
                                ) {
                                    HStack {
                                        Text(result)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .padding(.leading, 10)
                                        
                                        Spacer()
                                    }
                                }
                                .isDetailLink(false)
                            }
                        } // foreach
                    } // if else
                }
            }
        }
        .background(.white)
    }
}
