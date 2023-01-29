//
//  PostUpdateView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import AVKit
import NukeUI

struct PostUpdateView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var profileVM: MyProfileViewModel
    
    @State var updatePost: UpdatePost
    var post: Post
    let listIndex: Int
    let postIndex: Int
    
    @ObservedObject var sportSelectVM = SportSelectViewModel()
    
    @State private var sportSelectViewPresented = false
    @State private var findLocationViewPresented = false
    
    @State private var placeHolder = StringResources.postCreateContentPlaceholder
    
    @State var toastAlert = false
    @State var toastAlertOffset: CGFloat = 100
    
    @State var sportInfoAlert = false
    @State var placeInfoAlert = false
    
    init(post: Post, listIndex: Int, postIndex: Int) {
        self.post = post
        self.listIndex = listIndex
        self.postIndex = postIndex
        if self.post.like == nil {
            self.post.like = []
        }
        
        _updatePost = State(initialValue: UpdatePost(postCreatedAt: post.postCreatedAt, updatedAt: "", content: post.content, sportHashtag: post.sportHashtag, place: post.place, x: post.x, y: post.y))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    NavigationLink(
                        destination: { PostUpdateDetailView(post: post) }
                    ) {
                        Rectangle()
                            .fill(.white)
                            .aspectRatio(0.5625, contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width / 2)
                            .overlay(
                                ZStack {
                                    if post.mediaObj.first?.type == "image" {
                                        Rectangle()
                                            .fill(.white)
                                            .blendMode(.multiply)
                                            .background {
                                                ShadowView(
                                                    offset: CGSize(width: 0, height: -30),
                                                    width: 2000,
                                                    height: 0
                                                )
                                            }
                                        
                                        LazyImage(
                                            url: URL(string: post.mediaObj[0].url),
                                            resizingMode: .aspectFit
                                        )
                                        .blendMode(.multiply)
                                        
                                        VStack {
                                            Spacer()
                                            
                                            HStack {
                                                Text(updatePost.content)
                                                    .font(.subheadline)
                                                    .lineLimit(1)
                                                
                                                Spacer()
                                                
                                                Text(String(updatePost.place.split(separator: " ").last ?? ""))
                                                    .font(.subheadline)
                                                    .lineLimit(1)
                                            }
                                            .foregroundColor(.white)
                                            .padding(EdgeInsets(top: 0, leading: 4, bottom: 4, trailing: 4))
                                        }
                                    } else {
                                        VideoPlayer(player: AVPlayer(url: URL(string: post.mediaObj.first?.url ?? "")!))
                                    }
                                }
                            )
                    }
                    
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                        Text(StringResources.postUpdateMediaInfo)
                            .font(.footnote)
                    }
                    .padding(.top, 12)
                    .foregroundColor(.secondary)
                    
                    SportOrPlaceAddButton(
                        viewPresented: $sportSelectViewPresented,
                        placeholder: StringResources.sportPlaceholder,
                        sportHashtag: updatePost.sportHashtag,
                        required: true,
                        filled: !updatePost.sportHashtag.isEmpty,
                        infoRequired: true,
                        infoAlertAction: { sportInfoAlert = true }
                    )
                    .padding(.top, 8)
                    
                    SportOrPlaceAddButton(
                        viewPresented: $findLocationViewPresented,
                        placeholder: StringResources.locationPlaceholder,
                        place: updatePost.place,
                        placeText: String(updatePost.place.split(separator: " ").last ?? ""),
                        required: true,
                        filled: !updatePost.place.isEmpty,
                        infoRequired: true,
                        infoAlertAction: { placeInfoAlert = true },
                        deletePlace: { updatePost.place = "" }
                    )
                    
                    ContentTextField(
                        placeholder: $placeHolder,
                        content: $updatePost.content
                    )
                    
                    CompleteButton(
                        text: StringResources.complete,
                        enabled: !updatePost.sportHashtag.isEmpty && !updatePost.place.isEmpty,
                        loading: $profileVM.loading
                    ) {
                        profileVM.updatePost(updatePost: updatePost, listIndex: listIndex, postIndex: postIndex) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle(Text(StringResources.postUpdateNavigationTitle))
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text(StringResources.cancel)
                        }
                    }
                }
                .fullScreenCover(isPresented: $sportSelectViewPresented) {
                    SportSelectView(sportSelectVM: sportSelectVM) { selectedSport, userHashtag in
                        updatePost.sportHashtag = selectedSport
                        updatePost.userHashtag = userHashtag
                    }
                }
                .fullScreenCover(isPresented: $findLocationViewPresented) {
                    FindLocationView(setPlace: { item in
                        updatePost.place = item.address
                        updatePost.x = item.x
                        updatePost.y = item.y
                    })
                }
                .onTapGesture {
                    self.endTextEditing()
                }
                
                if sportInfoAlert {
                    InfoAlertView(
                        text: StringResources.postCreateSportInfo,
                        offset: CGSize(width: 16, height: 104)
                    )
                    .onTapGesture {
                        sportInfoAlert = false
                    }
                }
                
                if placeInfoAlert {
                    InfoAlertView(
                        text: StringResources.postCreateLocationInfo,
                        offset: CGSize(width: 16, height: 144)
                    )
                    .onTapGesture {
                        placeInfoAlert = false
                    }
                }
                
                if toastAlert {
                    ToastAlert(
                        toastAlert: $toastAlert,
                        toastAlertOffset: $toastAlertOffset,
                        text: StringResources.requiredFormAlertMessage
                    )
                }
            } // zstack
        } // navigationview
        .accentColor(Color("moare"))
        .onAppear {
            sportSelectVM.getSportList(sportHashtag: updatePost.sportHashtag)
        }
    }
}
