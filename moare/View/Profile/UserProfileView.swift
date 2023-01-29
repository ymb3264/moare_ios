//
//  UserProfileView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import StreamChat

struct UserProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var profileVM: UserProfileViewModel
    
    @Binding var myProfile: Profile
    @Binding var goMessageView: Bool
    @Binding var messageTarget: String
    
    @State var messageViewPresented = false
    
    @State var truncated = false
    @State var expanded = false
    
    @State var alert = false
    @State var alertState: UserProfileViewAlertState = .unfollow
    
    var body: some View {
            VStack {
                HStack(alignment: .top) {
                    AsyncImage(
                        url: URL(string: profileVM.userProfile.profileImage),
                        content: { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                        },
                        placeholder: {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 110))
                                .foregroundColor(.secondary)
                                .frame(width: 110, height: 110)
                        }
                    )
                    
                    VStack(spacing: 2) {
                        Text(profileVM.networkError ? StringResources.failedToGetProfileInfo : profileVM.userProfile.name)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                        
                        HStack(spacing: 1) {
                            Text(profileVM.userProfile.content)
                                .font(.body)
                                .lineLimit(expanded ? nil : 3)
                                .frame(alignment: .leading)
                                .background(
                                    Text(profileVM.userProfile.content)
                                        .font(.body)
                                        .frame(alignment: .leading)
                                        .lineLimit(3)
                                        .background(GeometryReader { visibleTextGeometry in
                                            ZStack {
                                                Text(profileVM.userProfile.content)
                                                    .font(.body)
                                                    .frame(alignment: .leading)
                                                    .background(GeometryReader { fullTextGeometry in
                                                        Color.clear.onAppear {
                                                            truncated = fullTextGeometry.size.height > visibleTextGeometry.size.height
                                                        }
                                                    })
                                            }
                                            .frame(height: .greatestFiniteMagnitude)
                                        })
                                        .hidden()
                                )
                            
                            if truncated {
                                VStack {
                                    Text("empty")
                                        .hidden()
                                    Text("empty")
                                        .hidden()
                                    Text(StringResources.seeMore)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        .onTapGesture {
                            expanded.toggle()
                            truncated.toggle()
                        }
                        
                        HStack {
                            if !profileVM.userProfile.place.isEmpty {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.subheadline)
                            }
                            
                            Text(profileVM.userProfile.place)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.leading, 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
                
                Text(profileVM.userProfile.sportHashtag?
                    .joined(separator: " ") ?? "")
                .font(.body)
                .foregroundColor(Color("moare"))
                .padding(.leading, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 0) {
                    NavigationLink(destination: {
                        FollowListView(
                            isTeam: profileVM.userProfile.isTeam,
                            selection: profileVM.userProfile.isTeam ? .member : .team,
                            teamOrMember: profileVM.userProfile.teamOrMember,
                            follower: profileVM.userProfile.follower,
                            following: profileVM.userProfile.following,
                            goMessageView: $goMessageView,
                            messageTarget: $messageTarget,
                            myProfile: $myProfile)
                    }) {
                        VStack {
                            Text("\(profileVM.userProfile.teamOrMember.count)")
                            Text(profileVM.userProfile.isTeam ? StringResources.member : StringResources.team)
                        }
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                    }
                    .isDetailLink(false)
                    
                    NavigationLink(destination: {
                        FollowListView(
                            isTeam: profileVM.userProfile.isTeam,
                            selection: .follower,
                            teamOrMember: profileVM.userProfile.teamOrMember,
                            follower: profileVM.userProfile.follower,
                            following: profileVM.userProfile.following,
                            goMessageView: $goMessageView,
                            messageTarget: $messageTarget,
                            myProfile: $myProfile)
                    }) {
                        VStack {
                            Text("\(profileVM.userProfile.follower.count)")
                            Text(StringResources.follower)
                        }
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                    }
                    .isDetailLink(false)
                    
                    NavigationLink(destination: {
                        FollowListView(
                            isTeam: profileVM.userProfile.isTeam,
                            selection: .following,
                            teamOrMember: profileVM.userProfile.teamOrMember,
                            follower: profileVM.userProfile.follower,
                            following: profileVM.userProfile.following,
                            goMessageView: $goMessageView,
                            messageTarget: $messageTarget,
                            myProfile: $myProfile)
                    }) {
                        VStack {
                            Text("\(profileVM.userProfile.following.count)")
                            Text(StringResources.following)
                        }
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                    }
                    .isDetailLink(false)
                }
                .padding(.top, 1)
                
                HStack(spacing: 20) {
                    if let blockerUser = Profile.decode(profileVM.profile).blockedUser {
                        if blockerUser.contains(profileVM.userProfile.userID! + "+" + profileVM.userProfile.createdAt) {
                            ProfileButton(text: StringResources.unblock) {
                                
                            }
                        } else {
                            // 내 계정이 아닐때
                            if !profileVM.accountsUsername.contains(profileVM.userProfile.username) {
                                ProfileButton(
                                    text: profileVM.followButtonEnabled ? StringResources.followButton : StringResources.unfollowButton,
                                    enabled: profileVM.followButtonEnabled,
                                    loading: profileVM.followLoading
                                ) {
                                    if profileVM.followButtonEnabled {
                                        profileVM.follow()
                                    } else {
                                        profileVM.checkUnfollow {
                                            alertState = .unfollow
                                            alert = true
                                        }
                                    }
                                }
                            }
                            
                            ProfileButton(text: StringResources.message) {
                                profileVM.createChannel { cid in
                                    self.messageTarget = cid
                                    self.goMessageView = true
                                }
                            }
                        }
                    } else {
                        if !profileVM.accountsUsername.contains(profileVM.userProfile.username) {
                            ProfileButton(
                                text: profileVM.followButtonEnabled ? StringResources.followButton : StringResources.unfollowButton,
                                enabled: profileVM.followButtonEnabled,
                                loading: profileVM.followLoading
                            ) {
                                if profileVM.followButtonEnabled {
                                    profileVM.follow()
                                } else {
                                    profileVM.checkUnfollow {
                                        alertState = .unfollow
                                        alert = true
                                    }
                                }
                            }
                        }
                        
                        ProfileButton(text: StringResources.message) {
                            profileVM.createChannel { cid in
                                self.messageTarget = cid
                                self.goMessageView = true
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.top, 4)
                    
                UserProfilePostListView(profileVM: profileVM)
            } // vstack
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(profileVM.userProfile.username)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            alertState = .report
                            alert = true
                        } label: {
                             Text(StringResources.report)
                                .font(.body)
                        }
                        Button(role: .destructive) {
                            alertState = .blockUser
                            alert = true
                        } label: {
                             Text(StringResources.block)
                                .font(.body)
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Circle()
                                .frame(width: 4, height: 4)
                            Circle()
                                .frame(width: 4, height: 4)
                            Circle()
                                .frame(width: 4, height: 4)
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .alert(isPresented: $alert) {
                if alertState == .unfollow {
                    return Alert(
                        title: Text(profileVM.alertTitle),
                        message: Text(profileVM.alertMessage),
                        primaryButton: .destructive(Text(StringResources.cancel)),
                        secondaryButton: .cancel(Text(StringResources.confirm), action: {
                            profileVM.unfollow()
                        })
                    )
                } else if alertState == .report {
                    return Alert(
                        title: Text(StringResources.reportUserAlertTitle),
                        message: Text(StringResources.reportUserAlertMessage),
                        primaryButton: .cancel(Text(StringResources.cancel)),
                        secondaryButton: .destructive(Text(StringResources.report)) {
                            profileVM.reportUser {
                                alertState = .reportSuccess
                                alert = true
                            }
                        }
                    )
                } else if alertState == .reportSuccess {
                    return Alert(
                        title: Text(StringResources.reportUserAlertTitle),
                        message: Text(StringResources.reportSuccessMessgae),
                        dismissButton: .cancel(Text(StringResources.confirm))
                    )
                } else if alertState == .blockUser {
                    return Alert(
                        title: Text(StringResources.blockUserAlertTitle),
                        message: Text(StringResources.blockUserAlertMessage),
                        primaryButton: .cancel(Text(StringResources.cancel)),
                        secondaryButton: .destructive(Text(StringResources.block)) {
                            profileVM.blockUser {
                                alertState = .blockUserSuccess
                                alert = true
                            }
                        }
                    )
                } else {
                    return Alert(
                        title: Text(StringResources.blockUserAlertTitle),
                        message: Text(profileVM.userProfile.username + StringResources.blockUserSuccessMessgae),
                        dismissButton: .cancel(Text(StringResources.confirm))
                    )
                }
            }
    }
}
