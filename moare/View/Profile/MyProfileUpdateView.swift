//
//  MyProfileUpdateView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import Mantis

struct MyProfileUpdateView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var postVM: PostViewModel
    @EnvironmentObject var profileVM: MyProfileViewModel
    @ObservedObject var sportSelectVM = SportSelectViewModel()
    
    @State private var photoPickerPresented = false
    @ObservedObject var mediaItems = PickedMediaItems(filter: .images, limit: 1)
    
    @State private var sportSelectViewPresented = false
    @State private var findLocationViewPresented = false
    
    @State private var placeHolder = StringResources.updateProfileContentPlaceholder
    @State private var content = ""
    
    @State private var alert = false
    
    @State private var selectedImage = UIImage()
    @State private var cropperPresented = false
    @State private var cropShapeType: Mantis.CropShapeType = .circle()
    @State private var presetFixedRatioType: Mantis.PresetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1)
    
    @State var isDefaultImage = false
    
    @State var toastAlert = false
    @State var toastAlertOffset: CGFloat = 100
    
    @State var sportInfoAlert = false
    @State var placeInfoAlert = false
    
    @State var trashBinding = false
    @State var trashPostCreateAlertBinding: PostCreateAlertState = .contentDelete
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    ProfileImageAddButton(
                        image: $selectedImage,
                        profileImage: profileVM.myProfile.profileImage,
                        isDefaultImage: $isDefaultImage,
                        action1: { photoPickerPresented = true },
                        action2: {
                            // profileImage가 있을때만 기본이미지로 변경했을시 shouldUpdatePost = true
                            selectedImage = UIImage()
                            isDefaultImage = true
                            if !profileVM.updatedUserProfile.profileImage.isEmpty {
                                profileVM.updatedUserProfile.shouldUpdateDefaultImage = true
                            }
                        }
                    )
                    
                    ProfileUsernameTextField(
                        placeholder: "사용자 이름",
                        text: $profileVM.updatedUserProfile.username,
                        loading: $profileVM.usernameLoading,
                        required: true,
                        filled: !profileVM.showErrorText && !profileVM.showErrorText2
                    ).onChange(of: profileVM.updatedUserProfile.username) { i in
                        profileVM.checkUsername(username: i)
                    }
                    
                    if profileVM.showErrorText || profileVM.showErrorText2 {
                        HStack {
                            Text(profileVM.showErrorText ? StringResources.usernameValidationError : StringResources.existingUsernameError)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.leading)
                            
                            Spacer()
                        }
                    }
                    
                    ProfileTextField(
                        placeholder: StringResources.namePlaceholder,
                        text: $profileVM.updatedUserProfile.name
                    )
                    
                    SportOrPlaceAddButton(
                        viewPresented: $sportSelectViewPresented,
                        placeholder: StringResources.sportPlaceholder,
                        sportHashtag: profileVM.updatedUserProfile.sportHashtag ?? [],
                        place: "",
                        infoRequired: true,
                        infoAlertAction: { sportInfoAlert = true }
                    )
                    
                    SportOrPlaceAddButton(
                        viewPresented: $findLocationViewPresented,
                        placeholder: StringResources.locationPlaceholder,
                        place: profileVM.updatedUserProfile.place,
                        placeText: String(profileVM.updatedUserProfile.place.split(separator: " ").last ?? ""),
                        infoRequired: true,
                        infoAlertAction: { placeInfoAlert = true },
                        deletePlace: { profileVM.updatedUserProfile.place = "" }
                    )
                    
                    ContentTextField(placeholder: $placeHolder, content: $profileVM.updatedUserProfile.content)
                        .padding(.top, 4)
                    
                    CompleteButton(
                        text: StringResources.complete,
                        enabled: profileVM.updateCompleteBtnEnabled,
                        loading: $profileVM.loading
                    ) {
                        profileVM.updateProfile(selectedImage: selectedImage) {
                            presentationMode.wrappedValue.dismiss()
                            // 24시간이내 올린 게시물이 있을때만으로 변경
                            postVM.getPosts()
                        }
                    }
                    .padding(.vertical)
                    .onTapGesture {
                        // 필수 작성칸 알림
                        if !profileVM.teamCompleteBtnEnabled {
                            toastAlert = true
                            withAnimation(.spring()) {
                                toastAlertOffset = 0
                            }
                        }
                    }
                } // vstack
                .navigationTitle(Text(StringResources.profileUpdateNavigationTitle))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if profileVM.checkUpdateContent(image: selectedImage) {
                                presentationMode.wrappedValue.dismiss()
                                profileVM.resetUpdateProfile()
                            } else {
                                alert = true
                            }
                        }) {
                            Text(StringResources.cancel)
                                .font(.body)
                        }
                    }
                }
                .alert(isPresented: $alert) {
                    Alert(
                        title: Text(StringResources.deleteFormTitle),
                        message: Text(StringResources.deleteFormMessage),
                        primaryButton: .destructive(Text(StringResources.cancel)),
                        secondaryButton: .cancel(Text(StringResources.confirm), action: {
                            presentationMode.wrappedValue.dismiss()
                            profileVM.resetUpdateProfile()
                        })
                    )
                }
                .fullScreenCover(
                    isPresented: $photoPickerPresented,
                    content: {
                        PhotoPicker(
                            mediaItems: mediaItems,
                            cropperPresented: $cropperPresented,
                            selectedImage: $selectedImage,
                            isDefaultImage: $isDefaultImage,
                            alert: $trashBinding,
                            postCreateAlertState: $trashPostCreateAlertBinding,
                            isPost: false
                        )
                    }
                )
                .fullScreenCover(isPresented: $sportSelectViewPresented) {
                    SportSelectView(sportSelectVM: sportSelectVM) { selectedSport, userHashtag in
                        profileVM.updatedUserProfile.sportHashtag = selectedSport
                        profileVM.updatedUserProfile.userHashtag = userHashtag
                    }
                }
                .fullScreenCover(isPresented: $findLocationViewPresented) {
                    FindLocationView(setPlace: { item in
                        profileVM.updatedUserProfile.place = item.address
                    })
                }
                .fullScreenCover(isPresented: $cropperPresented, content: {
                    ImageCropper(image: $selectedImage,
                                 cropShapeType: $cropShapeType,
                                 presetFixedRatioType: $presetFixedRatioType)
                    .ignoresSafeArea()
                })
                
                if sportInfoAlert {
                    InfoAlertView(
                        text: StringResources.sportInfo,
                        offset: CGSize(width: 10, height: 50)
                    )
                    .onTapGesture {
                        sportInfoAlert = false
                    }
                }
                
                if placeInfoAlert {
                    InfoAlertView(
                        text: StringResources.locationInfo,
                        offset: CGSize(width: 10, height: 82)
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
        .onTapGesture {
            self.endTextEditing()
        }
        .onAppear {
            if let sportHashtag = profileVM.updatedUserProfile.sportHashtag {
                sportSelectVM.getSportList(sportHashtag: sportHashtag)
            }
        }
    }
}
