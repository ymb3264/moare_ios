//
//  MainView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI
import Introspect

struct MainView: View {
    @StateObject var postVM = PostViewModel()
    @StateObject var profileVM = MyProfileViewModel()
    @StateObject var appState = AppState.shared

    @State var goPostCreateView = false
    @State var goMessageListView = false
    @State var goMessageView = false
    @State var messageTarget = ""
    
    @State var isPlaceSheet = false
    @State var customSheetBgPresented = false
    @State var customSheetOffset: CGFloat = 200
    
    @Injected(\.chatClient) var chatClient
    @Injected(\.fonts) var fonts
    
    var body: some View {
        NavigationView {
            ZStack {
                TabView(selection: $appState.selection) {
                    PostView(
                        postVM: postVM,
                        isPlaceSheet: $isPlaceSheet,
                        customSheetBgPresented: $customSheetBgPresented,
                        customSheetOffset: $customSheetOffset,
                        goPostCreateView: $goPostCreateView,
                        goMessageView: $goMessageView,
                        messageTarget: $profileVM.messageTarget,
                        myProfile: $profileVM.myProfile
                    ).tabItem {
                            Image(systemName: "rectangle.on.rectangle")
                        }
                    .tag(TabIdentifier.post)
                    
                    MyProfileView(
                        postVM: postVM,
                        profileVM: profileVM,
                        isPlaceSheet: $isPlaceSheet,
                        customSheetBgPresented: $customSheetBgPresented,
                        customSheetOffset: $customSheetOffset,
                        goMessageListView: $goMessageListView,
                        goMessageView: $goMessageView,
                        messageTarget: $profileVM.messageTarget
                    ).tabItem {
                        Image(systemName: "person")
                    }
                    .tag(TabIdentifier.profile)
                }
//                .introspectNavigationController { controller in
//                    controller.navigationBar.isHidden = appState.navigationBarHidden
//                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
                .onAppear {
                    let tabBarAppearance = UITabBarAppearance()
                    tabBarAppearance.configureWithOpaqueBackground()
                    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
//                    appState.navigationBarHidden = true
                }

                // customSheet
                if customSheetBgPresented {
                    CustomBottomSheetBg(
                        customSheetBgPresented: $customSheetBgPresented,
                        customSheetOffset: $customSheetOffset
                    )
                }
                if isPlaceSheet {
                    PlacesBottomSheet(
                        customSheetBgPresented: $customSheetBgPresented,
                        customSheetOffset: $customSheetOffset,
                        postVM: postVM
                    )
                } else {
                    AccountsBottomSheet(
                        customSheetBgPresented: $customSheetBgPresented,
                        customSheetOffset: $customSheetOffset,
                        profileVM: profileVM,
                        postVM: postVM
                    )
                }
                
                NavigationLink(
                    isActive: $goPostCreateView,
                    destination: {
                        NavigationLazyView(PostCreateView(postVM: postVM, profileVM: profileVM))
                    }
                ) {
                    EmptyView()
                }.disabled(true)
                
                // streamchat
                NavigationLink(
                    isActive: $goMessageListView,
                    destination: {
                        NavigationLazyView(
                            ChatChannelListView(viewFactory: CustomUIFactory.shared)
                                .toolbar {
                                    ToolbarItem(placement: .principal) {
                                        Text(StringResources.message)
                                            .font(fonts.bodyBold)
                                    }
                                }
                                .alert(isPresented: $appState.channelDeleteAlert) {
                                    if appState.isDirectMessage {
                                        return Alert(
                                            title: Text(StringResources.deleteChannelAlertTitle),
                                            message: Text(StringResources.deleteChannelAlertMessage),
                                            primaryButton: .cancel(Text(StringResources.cancel)),
                                            secondaryButton: .destructive(Text(StringResources.delete), action: {
                                                let channelClient = self.chatClient.channelController(for: appState.channelId)
                                                channelClient.deleteChannel()
                                            })
                                        )
                                    } else {
                                        return Alert(
                                            title: Text(StringResources.leaveTeamChannelAlertTitle),
                                            message: Text(StringResources.leaveTeamChannelAlertMessage),
                                            dismissButton: .cancel(Text(StringResources.confirm))
                                        )
                                    }
                                }
                        )
                    }
                ) {
                    EmptyView()
                }.disabled(true)
                
                NavigationLink(
                    isActive: $goMessageView,
                    destination: {
                        NavigationLazyView(
                            ChatChannelView(
                                viewFactory: CustomUIFactory.shared,
                                channelController:  chatClient.channelController(
                                    for: ChannelId(type: .messaging, id: profileVM.messageTarget)
                                )
                            )
                        )
                    }
                ) {
                    EmptyView()
                }
                .isDetailLink(false)
            } // zstack
        } // navigationview
        .accentColor(Color("moare"))
        .navigationViewStyle(.stack)
    }
}
