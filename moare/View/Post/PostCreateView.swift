//
//  PostCreateView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import AVKit
import Introspect

struct PostCreateView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var postVM: PostViewModel
    @StateObject var profileVM: MyProfileViewModel
    
    @ObservedObject var postCreateVM = PostCreateViewModel()
    @ObservedObject var sportSelectVM = SportSelectViewModel()
    
    @State var photoPickerPresented = false
    @StateObject var mediaItems = PickedMediaItems(filter: .any(of: [.images, .videos]), limit: 0)
    
    @State private var sportSelectViewPresented = false
    @State private var findLocationViewPresented = false
    @State private var cropperPresented = false
    @State private var showDetailView = false
    
    @State private var placeHolder = StringResources.postCreateContentPlaceholder
    
    @State private var selectedImage = UIImage()
    
    @State var defaultBool = false
    
    @State var alertRequired = false
    @State var toastAlert = false
    @State var toastAlertOffset: CGFloat = 100
    
    // info
    @State var sportInfoAlert = false
    @State var placeInfoAlert = false
    @State var mediaInfoAlert = false
    
    @State private var alert = false
    @State private var postCreateAlertState: PostCreateAlertState = .contentDelete
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Button(action: {
                        photoPickerPresented.toggle()
                    }) {
                        MediaPickerView(
                            placeholder: StringResources.addMediaPlaceholder,
                            infoRequired: true,
                            infoAlertAction: { mediaInfoAlert = true },
                            mediaItems: mediaItems,
                            postCreatVM: postCreateVM
                        )
                    }
                    
                    NavigationLink(
                        isActive: $showDetailView,
                        destination: {
                            PostCreateDetailView(
                                postCreateVM: postCreateVM,
                                mediaItems: mediaItems)
                        }
                    ) {
                        MediaPickerView(
                            placeholder: StringResources.postCreatePreviewPlaceholder,
                            isPreview: true,
                            mediaItems: mediaItems,
                            postCreatVM: postCreateVM
                        )
                    }
                    .disabled(self.mediaItems.items.isEmpty)
                }
                .padding(.horizontal)
                
                HStack {
                    Image(systemName: "exclamationmark.circle")
                    Text(StringResources.postCreateMediaDeleteInfo)
                        .font(.footnote)
                }
                .padding(.top, 12)
                .foregroundColor(.secondary)
                
                SportOrPlaceAddButton(
                    viewPresented: $sportSelectViewPresented,
                    placeholder: StringResources.sportPlaceholder,
                    sportHashtag: postCreateVM.post.sportHashtag,
                    required: true,
                    filled: !postCreateVM.post.sportHashtag.isEmpty,
                    infoRequired: true,
                    infoAlertAction: { sportInfoAlert = true }
                )
                .padding(.top, 8)
                
                SportOrPlaceAddButton(
                    viewPresented: $findLocationViewPresented,
                    placeholder: StringResources.locationPlaceholder,
                    place: postCreateVM.post.place,
                    placeText: String(postCreateVM.currentLocation.split(separator: " ").last ?? ""),
                    required: true,
                    filled: !postCreateVM.post.place.isEmpty,
                    infoRequired: true,
                    infoAlertAction: { placeInfoAlert = true },
                    deletePlace: { postCreateVM.post.place = "" }
                )
                
                ContentTextField(
                    placeholder: $placeHolder,
                    content: $postCreateVM.post.content
                )
                
                CompleteButton(
                    text: StringResources.upload,
                    enabled: postCreateVM.completeBtnEnabled,
                    loading: $postCreateVM.loading
                ) {
                    postCreateVM.createPost(mediaItems: mediaItems) {
                        postVM.getPosts()
                        profileVM.getUserPosts()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding(.vertical)
                .onTapGesture {
                    // 필수 작성칸 알림
                    if !postCreateVM.completeBtnEnabled {
                        toastAlert = true
                        withAnimation(.spring()) {
                            toastAlertOffset = 0
                        }
                    }
                }
                .onChange(of: postCreateVM.post) { _ in
                    postCreateVM.checkCompleteBtn(mediaItems: mediaItems)
                }
            }
            .navigationTitle(Text(StringResources.postCreateNavigationTitle))
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if postCreateVM.checkContent(mediaItems: mediaItems) {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            postCreateAlertState = .contentDelete
                            alert = true
                        }
                    }) {
                        Text(StringResources.cancel)
                            .font(.body)
                    }
                }
            }
            .alert(isPresented: $alert) {
                if postCreateAlertState == .contentDelete {
                    return Alert(
                        title: Text(StringResources.deleteFormTitle),
                        message: Text(StringResources.deleteFormMessage),
                        primaryButton: .destructive(Text(StringResources.cancel)),
                        secondaryButton: .cancel(Text(StringResources.confirm), action: {
                            presentationMode.wrappedValue.dismiss()
                        })
                    )
                } else if postCreateAlertState == .videoDurationLimit {
                    return Alert(
                        title: Text(StringResources.videoLengthLimitAlertTitle),
                        message: Text(StringResources.videoLenthLimitAlertMessage),
                        dismissButton: .cancel(Text(StringResources.confirm))
                    )
                } else {
                    return Alert(
                        title: Text(StringResources.mediaCountLimitAlertTitle),
                        message: Text(StringResources.mediaCountLimitAlertMessage),
                        dismissButton: .cancel(Text(StringResources.confirm))
                    )
                }
            }
            .fullScreenCover(
                isPresented: $photoPickerPresented,
                content: {
                    PhotoPicker(
                        mediaItems: mediaItems,
                        cropperPresented: $cropperPresented,
                        selectedImage: $selectedImage,
                        isDefaultImage: $defaultBool,
                        alert: $alert,
                        postCreateAlertState: $postCreateAlertState,
                        checkCompleteBtn: { postCreateVM.checkCompleteBtn(mediaItems: mediaItems) }
                    )
                }
            )
            .fullScreenCover(isPresented: $sportSelectViewPresented) {
                SportSelectView(sportSelectVM: sportSelectVM) { selectedSport, userHashtag  in
                    postCreateVM.post.sportHashtag = selectedSport
                    postCreateVM.post.userHashtag = userHashtag
                }
            }
            .fullScreenCover(isPresented: $findLocationViewPresented) {
                FindLocationView(setPlace: { item in
                    postCreateVM.post.place = item.address
                    postCreateVM.post.x = item.x
                    postCreateVM.post.y = item.y
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
            
            if mediaInfoAlert {
                InfoAlertView(
                    text: StringResources.postCreateMediaInfo,
                    offset: CGSize(width: 24, height: -112)
                )
                .onTapGesture {
                    mediaInfoAlert = false
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
    }
}
