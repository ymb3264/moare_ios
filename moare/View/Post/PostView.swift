//
//  PostView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import AVKit

struct PostView: View {
    @StateObject var postVM: PostViewModel
    @StateObject var appState = AppState.shared
    
    @AppStorage("currentLocation") var currentLocation = ""
 
    @Binding var isPlaceSheet: Bool
    @Binding var customSheetBgPresented: Bool
    @Binding var customSheetOffset: CGFloat
    
    @Binding var goPostCreateView: Bool
    @Binding var goMessageView: Bool
    @Binding var messageTarget: String
    
    @Binding var myProfile: Profile
    
    @State var showDetail = false
    @State private var enabled = false
    @State var setLocation = false
    @State private var alert = false
    
    var body: some View {
            NavigationView {
                ZStack {
                    if self.currentLocation.isEmpty {
                        VStack {
                            Text(StringResources.setCurrentLocationMessage)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)

                            Button(StringResources.setCurrentLocation) {
                                setLocation = true
                            }
                        }
                        .navigationBarHidden(appState.postSearchBar)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                HStack {
                                    Button(action: {
                                        appState.postSearchBar = true
                                    }) {
                                        Image(systemName: "magnifyingglass")
                                    }
                                    Button(action: {
                                        self.alert = true
                                    }) {
                                        Image(systemName: "plus.app")
                                    }
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        .alert(isPresented: $alert) {
                            Alert(
                                title: Text(StringResources.createPostAlertTitle),
                                message: Text(StringResources.createdPostAlertMessage),
                                dismissButton: .cancel(Text(StringResources.confirm))
                            )
                        }
                        .fullScreenCover(isPresented: $setLocation, onDismiss: {}, content: {
                            FindLocationView(setDefault: true)
                        })
                    } else {
                        PostListView()
                            .navigationBarHidden(appState.postSearchBar)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    postVM.setLocationList()
                                    isPlaceSheet = true
                                    customSheetBgPresented = true
                                    withAnimation(.spring(dampingFraction: 1)) {
                                        customSheetOffset = 0
                                    }
                                }) {
                                    Text(String(self.currentLocation.split(separator: " ").last ?? ""))
                                        .font(.title3)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.footnote)
                                        .foregroundColor(.primary)
                                }
                                .foregroundColor(.primary)
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                HStack {
                                    Button(action: {
                                        appState.postSearchBar = true
                                    }) {
                                        Image(systemName: "magnifyingglass")
                                    }
                                    Button(action: {
                                        self.goPostCreateView = true
                                    }) {
                                        Image(systemName: "plus.app")
                                    }
                                }
                                .foregroundColor(.primary)
                            }
                        }
                    } // if else
                    
                    if appState.postSearchBar {
                        PostSearchView(
                            goMessageView: $goMessageView,
                            messageTarget: $messageTarget,
                            myProfile: $myProfile
                        )
                    }
                    
                    NavigationLink(
                        isActive: $appState.isDeepLinkActive,
                        destination: {
                            NavigationLazyView(DeepLinkPostDetailView(yearAndMonth: appState.yearAndMonth, postCreatedAt: appState.postCreatedAt))
                        }
                    ) {
                        EmptyView()
                    }
                } // zstack
                .navigationTitle("")
            } // navigationview
            .accentColor(Color("moare"))
            .navigationViewStyle(.stack)
            .environmentObject(postVM)
            .onOpenURL { url in
                if let yearAndMonth = url.yearAndMonth,
                   let postCreatedAt = url.postCreatedAt {
                    appState.yearAndMonth = yearAndMonth
                    appState.postCreatedAt = postCreatedAt
                    appState.isDeepLinkActive = true
                }
            }
            .onChange(of: self.currentLocation) { _ in
                if self.currentLocation.isEmpty {
                    postVM.postsList.removeAll()
                    postVM.postsData = [Post]()
                    postVM.postNum = 6
                } else {
                    postVM.getPosts()
                }
            }
    } // body
}
