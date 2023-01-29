//
//  TeamProfileCreateView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import Mantis

struct TeamProfileCreateView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var profileVM: MyProfileViewModel
    @ObservedObject var sportSelectVM = SportSelectViewModel()
    
    @State private var photoPickerPresented = false
    var mediaItems = PickedMediaItems(filter: .images, limit: 1)
    
    @State private var sportSelectViewPresented = false
    @State private var findLocationViewPresented = false
    
    @State private var placeHolder = StringResources.teamProfileCreateContentPlaceholder
    @State private var content = ""
    
    @State private var alert = false
    
    @State private var selectedImage = UIImage()
    @State private var cropperPresented = false
    @State private var cropShapeType: Mantis.CropShapeType = .circle()
    @State private var presetFixedRatioType: Mantis.PresetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1)
    
    @State var isDefaultImage = false
    
    @State var toastAlert = false
    @State var toastAlertOffset: CGFloat = 100
    
    @State var teamNameInfoAlert = false
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
                        isDefaultImage: $isDefaultImage,
                        action1: { photoPickerPresented = true },
                        action2: {
                            selectedImage = UIImage()
                            isDefaultImage = true
                        }
                    )
                    
                    ProfileTextField(
                        placeholder: "",
                        text: $profileVM.username,
                        readOnly: true,
                        required: true,
                        filled: !profileVM.username.isEmpty
                    )
                    
                    ProfileUsernameTextField(
                        placeholder: StringResources.teamUsernamePlaceholder,
                        text: $profileVM.newTeamProfile.username,
                        loading: $profileVM.usernameLoading,
                        required: true,
                        filled: profileVM.newTeamProfile.username.isEmpty ? false : (!profileVM.showErrorText && !profileVM.showErrorText2)
                    ).onChange(of: profileVM.newTeamProfile.username) { i in
                        profileVM.checkTeamUsername(username: i)
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
                        placeholder: StringResources.teamNamePlaceholder,
                        text: $profileVM.newTeamProfile.name,
                        required: true,
                        filled: !profileVM.newTeamProfile.name.isEmpty,
                        infoRequired: true,
                        infoAlertAction: { teamNameInfoAlert = true }
                    ).onChange(of: profileVM.newTeamProfile.name) { i in
                        profileVM.checkCompleteBtn(isTeam: true)
                    }
                    
                    SportOrPlaceAddButton(
                        viewPresented: $sportSelectViewPresented,
                        placeholder: StringResources.sportPlaceholder,
                        sportHashtag: profileVM.newTeamProfile.sportHashtag ?? [],
                        place: "",
                        infoRequired: true,
                        infoAlertAction: { sportInfoAlert = true }
                    )
                    
                    SportOrPlaceAddButton(
                        viewPresented: $findLocationViewPresented,
                        placeholder: StringResources.locationPlaceholder,
                        place: profileVM.newTeamProfile.place,
                        placeText: String(profileVM.newTeamProfile.place.split(separator: " ").last ?? ""),
                        infoRequired: true,
                        infoAlertAction: { placeInfoAlert = true },
                        deletePlace: { profileVM.newTeamProfile.place = "" }
                    )
                    
                    ContentTextField(placeholder: $placeHolder, content: $profileVM.newTeamProfile.content)
                        .padding(.top, 4)
                    
                    CompleteButton(
                        text: StringResources.createProfileButton,
                        enabled: profileVM.teamCompleteBtnEnabled,
                        loading: $profileVM.loading
                    ) {
                        profileVM.createTeamProfile(profileImage: selectedImage) {
                            presentationMode.wrappedValue.dismiss()
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
                .navigationTitle(Text(StringResources.teamProfileCreateNavigationTitle))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if profileVM.checkTeamContent(image: selectedImage) {
                                presentationMode.wrappedValue.dismiss()
                                profileVM.resetTeamProfile()
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
                            profileVM.resetTeamProfile()
                            presentationMode.wrappedValue.dismiss()
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
                        profileVM.newTeamProfile.sportHashtag = selectedSport
                        profileVM.newTeamProfile.userHashtag = userHashtag
                    }
                }
                .fullScreenCover(isPresented: $findLocationViewPresented) {
                    FindLocationView(setPlace: { item in
                        profileVM.newTeamProfile.place = item.address
                    })
                }
                .fullScreenCover(isPresented: $cropperPresented, content: {
                    ImageCropper(image: $selectedImage,
                                 cropShapeType: $cropShapeType,
                                 presetFixedRatioType: $presetFixedRatioType)
                    .ignoresSafeArea()
                })
                
                if teamNameInfoAlert {
                    InfoAlertView(
                        text: StringResources.teamNameInfo,
                        offset: CGSize(width: 16, height: 46)
                    )
                    .onTapGesture {
                        teamNameInfoAlert = false
                    }
                }
                
                if sportInfoAlert {
                    InfoAlertView(
                        text: StringResources.sportInfo,
                        offset: CGSize(width: 10, height: 70)
                    )
                    .onTapGesture {
                        sportInfoAlert = false
                    }
                }
                
                if placeInfoAlert {
                    InfoAlertView(
                        text: StringResources.locationInfo,
                        offset: CGSize(width: 10, height: 104)
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
    }
}
