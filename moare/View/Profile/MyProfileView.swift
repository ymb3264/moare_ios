//
//  MyProfileView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct MyProfileView: View {
    @StateObject var postVM: PostViewModel
    @StateObject var profileVM: MyProfileViewModel
    
    @StateObject var appState = AppState.shared
    
    @AppStorage("profile") var profile = ""
    
    @Binding var isPlaceSheet: Bool
    @Binding var customSheetBgPresented: Bool
    @Binding var customSheetOffset: CGFloat
    
    @Binding var goMessageListView: Bool
    @Binding var goMessageView: Bool
    @Binding var messageTarget: String
    
    @State var teamProfileCreateViewPresented = false
    @State var updateProfileViewPresented = false
    
    @State var alert = false
    
    @State var truncated = false
    @State var expanded = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(alignment: .top) {
                        AsyncImage(
                            url: URL(string: profileVM.myProfile.profileImage),
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
                            Text(profileVM.profileNetworkError ? StringResources.failedToGetProfileInfo : profileVM.myProfile.name)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                                .padding(.bottom, 4)

                            HStack(spacing: 1) {
                                Text(profileVM.myProfile.content)
                                    .font(.body)
                                    .lineLimit(expanded ? nil : 3)
                                    .frame(alignment: .leading)
                                    .background(
                                        Text(profileVM.myProfile.content)
                                            .font(.body)
                                            .lineLimit(3)
                                            .frame(alignment: .leading)
                                            .background(GeometryReader { visibleTextGeometry in
                                                ZStack {
                                                    Text(profileVM.myProfile.content)
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
                                if !profileVM.myProfile.place.isEmpty {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.subheadline)
                                }
                                
                                Text(profileVM.myProfile.place)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.leading, 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    
                Text(profileVM.myProfile.sportHashtag?.joined(separator: " ") ?? "")
                    .font(.body)
                    .foregroundColor(Color("moare"))
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 0) {
                        NavigationLink(destination: {
                            FollowListView(
                                isTeam: profileVM.myProfile.isTeam,
                                selection: profileVM.myProfile.isTeam ? .member : .team,
                                teamOrMember: Profile.decode(self.profile).teamOrMember,
                                follower: Profile.decode(self.profile).follower,
                                following: Profile.decode(self.profile).following,
                                goMessageView: $goMessageView,
                                messageTarget: $messageTarget,
                                myProfile: $profileVM.myProfile)
                        }) {
                            VStack {
                                Text("\(Profile.decode(self.profile).teamOrMember.count)")
                                Text(profileVM.myProfile.isTeam ? StringResources.member : StringResources.team)
                            }
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                        }
                        
                        NavigationLink(destination: {
                            FollowListView(
                                isTeam: profileVM.myProfile.isTeam,
                                selection: .follower,
                                teamOrMember: Profile.decode(self.profile).teamOrMember,
                                follower: Profile.decode(self.profile).follower,
                                following: Profile.decode(self.profile).following,
                                goMessageView: $goMessageView,
                                messageTarget: $messageTarget,
                                myProfile: $profileVM.myProfile)
                        }) {
                            VStack {
                                Text("\(Profile.decode(self.profile).follower.count)")
                                Text(StringResources.follower)
                            }
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                        }
                        
                        NavigationLink(destination: {
                            FollowListView(
                                isTeam: profileVM.myProfile.isTeam,
                                selection: .following,
                                teamOrMember: Profile.decode(self.profile).teamOrMember,
                                follower: Profile.decode(self.profile).follower,
                                following: Profile.decode(self.profile).following,
                                goMessageView: $goMessageView,
                                messageTarget: $messageTarget,
                                myProfile: $profileVM.myProfile)
                        }) {
                            VStack {
                                Text("\(Profile.decode(self.profile).following.count)")
                                Text(StringResources.following)
                            }
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                        }
                    } // hstack(follow)
                    .padding(.top, 1)
                    
                    HStack(spacing: 20) {
                        if profileVM.myProfile.isTeam {
                            ProfileButton(text: StringResources.message) {
                                self.messageTarget = profileVM.myProfile.name
                                self.goMessageView = true
                            }
                        } else {
                            ProfileButton(text: StringResources.teamProfileCreateButton) {
                                if profileVM.myAccounts.count <= 10 {
                                    teamProfileCreateViewPresented = true
                                } else {
                                    alert = true
                                }
                            }
                        }
                        ProfileButton(text: StringResources.profileUpdateButton) { updateProfileViewPresented = true }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.top, 4)
                
                    ProfilePostListView(profileVM: profileVM)
            } // vstack
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            profileVM.refreshAccounts()
                            isPlaceSheet = false
                            customSheetBgPresented = true
                            withAnimation(.spring(dampingFraction: 1)) {
                                customSheetOffset = 0
                            }
                        }) {
                            Text(profileVM.myProfile.username)
                                .font(.title3)
                            
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 13))
                                .foregroundColor(.primary)
                        }
                        .foregroundColor(.primary)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: {
                                self.goMessageListView = true
                                AppState.shared.selection = TabIdentifier.profile
                            }) {
                                Image(systemName: "message")
                            }
                            
                            NavigationLink(
                                isActive: $appState.profileRootActive,
                                destination: { NavigationLazyView(SettingsView()) }
                            ) {
                                Image(systemName: "gearshape")
                            }
                            .isDetailLink(false)
                        }
                        .foregroundColor(.primary)
                    }
                    
                }
                .alert(isPresented: $alert) {
                    Alert(
                        title: Text(StringResources.teamProfileLimitAlertTitle),
                        message: Text(StringResources.teamProfileLimitAlertMessage),
                        dismissButton: .cancel(Text(StringResources.confirm))
                    )
                }
                .fullScreenCover(isPresented: $teamProfileCreateViewPresented, content: { TeamProfileCreateView() })
                .fullScreenCover(isPresented: $updateProfileViewPresented, content: { MyProfileUpdateView() })
        } // navigationView
        .accentColor(Color("moare"))
        .navigationViewStyle(.stack)
        .environmentObject(postVM)
        .environmentObject(profileVM)
    }
}
