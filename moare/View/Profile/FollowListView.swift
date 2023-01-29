//
//  FollowListView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import NukeUI

struct FollowListView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var isTeam: Bool = false
    @State var selection: Selected
    let teamOrMember: [FollowObj]
    let follower: [FollowObj]
    let following: [FollowObj]
    
    @Binding var goMessageView: Bool
    @Binding var messageTarget: String
    @Binding var myProfile: Profile
    
    @Namespace var namespace
    
    var body: some View {
        VStack {
            HStack(spacing: 2) {
                FollowListTabBarButton(
                    selection: $selection,
                    tab: isTeam ? .member : .team,
                    namespace: namespace
                )
                FollowListTabBarButton(selection: $selection, tab: .follower, namespace: namespace)
                FollowListTabBarButton(selection: $selection, tab: .following, namespace: namespace)
            }
            .padding(.horizontal, 5)
            
            TabView(selection: $selection) {
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(teamOrMember, id: \.self) { obj in
                            NavigationLink(
                                destination:
                                    UserProfileView(
                                        profileVM: UserProfileViewModel(username: obj.username),
                                        myProfile: $myProfile,
                                        goMessageView: $goMessageView,
                                        messageTarget: $messageTarget)
                            ) {
                                HStack {
                                    AsyncImage(
                                        url: URL(string: obj.profileImage),
                                        content: { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 48, height: 48)
                                                .clipShape(Circle())
                                        },
                                        placeholder: {
                                            Image(systemName: "person.crop.circle")
                                                .font(.system(size: 48))
                                                .foregroundColor(.secondary)
                                                .frame(width: 48, height: 48)
                                        }
                                    )
                                    
                                    Text(obj.username)
                                        .font(.title3)
                                        .foregroundColor(.primary)
                                        .padding(.leading, 8)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 8)
                            }
                            .isDetailLink(false)
                        }
                    }
                }
                .tag(isTeam ? Selected.member : Selected.team)
                
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(follower, id: \.self) { obj in
                            NavigationLink(
                                destination:
                                    UserProfileView(
                                        profileVM: UserProfileViewModel(username: obj.username),
                                        myProfile: $myProfile,
                                        goMessageView: $goMessageView,
                                        messageTarget: $messageTarget)
                            ) {
                                HStack {
                                    AsyncImage(
                                        url: URL(string: obj.profileImage),
                                        content: { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 48, height: 48)
                                                .clipShape(Circle())
                                        },
                                        placeholder: {
                                            Image(systemName: "person.crop.circle")
                                                .font(.system(size: 48))
                                                .foregroundColor(.secondary)
                                                .frame(width: 48, height: 48)
                                        }
                                    )
                                    
                                    Text(obj.username)
                                        .font(.title3)
                                        .foregroundColor(.primary)
                                        .padding(.leading, 8)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 8)
                            }
                            .isDetailLink(false)
                        }
                    }
                }
                .tag(Selected.follower)
                //
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(following, id: \.self) { obj in
                            NavigationLink(
                                destination:
                                    UserProfileView(
                                        profileVM: UserProfileViewModel(username: obj.username),
                                        myProfile: $myProfile,
                                        goMessageView: $goMessageView,
                                        messageTarget: $messageTarget)
                            ) {
                                HStack {
                                    AsyncImage(
                                        url: URL(string: obj.profileImage),
                                        content: { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 48, height: 48)
                                                .clipShape(Circle())
                                        },
                                        placeholder: {
                                            Image(systemName: "person.crop.circle")
                                                .font(.system(size: 48))
                                                .foregroundColor(.secondary)
                                                .frame(width: 48, height: 48)
                                        }
                                    )
                                    
                                    Text(obj.username)
                                        .font(.title3)
                                        .foregroundColor(.primary)
                                        .padding(.leading, 8)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 8)
                            }
                            .isDetailLink(false)
                        }
                    }
                }
                .tag(Selected.following)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        } // vstack
        .navigationTitle("")
    }
}
