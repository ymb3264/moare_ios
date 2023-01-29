//
//  Common.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct AccountsBottomSheet: View {
    @Binding var customSheetBgPresented: Bool
    @Binding var customSheetOffset: CGFloat
    @StateObject var profileVM: MyProfileViewModel
    @StateObject var postVM: PostViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                Rectangle()
                    .fill(.white)
                    .frame(height: 10)
                
                if profileVM.accountsNetworkError {
                    Text(StringResources.failedToGetProfileInfo)
                    .font(.body)
                }
                           
                ScrollView {
                    ForEach(profileVM.myAccounts.indices, id: \.self) { i in
                        Button(action: {
                            profileVM.changeProfile(username: profileVM.myAccounts[i].username) {
                                // currentlocation변경으로하면 indexoutof range에러남
                                postVM.getPosts()
                                
                                withAnimation(.easeIn) {
                                    customSheetOffset = 200
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    customSheetBgPresented = false
                                }
                            }
                        }) {
                            AsyncImage(
                                url: URL(string: profileVM.myAccounts[i].profileImage),
                                content: { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                },
                                placeholder: {
                                    Image(systemName: "person.crop.circle")
                                        .font(.system(size: 30))
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.secondary)
                                }
                            )
                            .padding(.leading)
                            
                            Text(profileVM.myAccounts[i].username)
                                .font(.body)
                                .padding(.leading, 4)
                                .foregroundColor(.primary)
                            
                            if profileVM.username == profileVM.myAccounts[i].username {
                                Circle()
                                    .fill(Color("moare"))
                                    .frame(width: 10, height: 10)
                            }
                            
                            Spacer()
                        }
                        
                        if i != profileVM.myAccounts.count - 1 {
                            Rectangle()
                                .fill(.gray)
                                .frame(height: 1)
                        }
                    }
                }
                
                Spacer()
            }
            .background(.white)
            .frame(maxWidth: .infinity, maxHeight: 200)
            .cornerRadius(20)
            .offset(y: customSheetOffset)
        }
        .ignoresSafeArea()
    }
}

struct CustomBottomSheetBg: View {
    @Binding var customSheetBgPresented: Bool
    @Binding var customSheetOffset: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(.secondary)
            .opacity(0.7)
            .onTapGesture {
                withAnimation(.easeIn) {
                    customSheetOffset = 200
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    customSheetBgPresented = false
                }
            }
            .ignoresSafeArea()
    }
}

struct ShadowView: View {
    var radius: CGFloat = 10
    var opacity: Double = 0.4
    var offset: CGSize
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        Rectangle()
            .opacity(0)
            .blendMode(.multiply)
            .background {
                ZStack {
                    Rectangle().fill(.gray).frame(width: width)
                    Rectangle().fill(.white).blur(radius: radius).offset(offset)
                }
            }
            .mask(Rectangle())
    }
}

struct SearchBarView: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")

            TextField(placeholder, text: $text)
                .foregroundColor(.primary)

            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                }
            } else {
                EmptyView()
            }
        }
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
        .foregroundColor(.secondary)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(5)
        .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
    }
}

struct SportSelectItem: View {
    var text: String
    var selected: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selected ? Color("moare") : .secondary.opacity(0), lineWidth: 2)
                )
            
            Rectangle()
                .frame(height: 2)
                .foregroundColor(selected ? .white.opacity(0) : .secondary)
        }
    }
}

struct SportOrPlaceAddButton: View {
    @Binding var viewPresented: Bool
    var placeholder: String
    var sportHashtag: [String] = []
    var place: String = ""
    var placeText: String = ""
    var required = false
    var filled = false
    var alertRequired = false
    var infoRequired = false
    var infoAlertAction: () -> () = {}
    var deletePlace: () -> () = {}
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                if required {
                    Rectangle()
                        .fill(Color("moare"))
                        .frame(maxWidth: 1, maxHeight: filled ? .infinity : 5)
                        .animation(.spring(), value: filled)
                }
                
                if infoRequired {
                    Button {
                        infoAlertAction()
                    } label: {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: {
                    viewPresented = true
                }) {
                    HStack {
                        if !place.isEmpty {
                            Text(placeText)
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            Rectangle()
                                .foregroundColor(.secondary)
                                .frame(width: 1, height: 15)
                            
                            Text(place)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .onTapGesture {
                                    deletePlace()
                                }
                        } else if !sportHashtag.isEmpty {
                            ForEach(sportHashtag.indices, id: \.self) { i in
                                Text(sportHashtag[i])
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                if i != sportHashtag.count - 1 {
                                    Rectangle()
                                        .foregroundColor(.black)
                                        .frame(width: 1, height: 15)
                                }
                            }
                        } else {
                            Text(placeholder)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                } // button
                .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: 40)
            
            if alertRequired && !filled {
                Rectangle()
                    .fill(Color("moare"))
                    .frame(height: 1)
            }
        }
        .padding(.horizontal)
    }
}

struct CompleteButton: View {
    var text: String
    var enabled = false
    @Binding var loading: Bool
    var action: () -> () = {}
    
    var body: some View {
        Button(action: action) {
            if loading {
                ProgressView()
                    .tint(Color("moare"))
            } else {
                Text(text)
                    .font(.body)
            }
        }
        .frame(maxWidth: 72, maxHeight: 36)
        .foregroundColor(enabled ? Color("moare") : .secondary)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(enabled ? Color("moare") : .secondary, lineWidth: 1)
        )
        .disabled(!enabled)
    }
}

struct ContentTextField: View {
    @Binding var placeholder: String
    @Binding var content: String
    var required = false
    var filled = false
    
    var body: some View {
        HStack(spacing: 0) {
            if required {
                Rectangle()
                    .fill(Color("moare"))
                    .frame(maxWidth: 1, maxHeight: filled ? .infinity : 5)
                    .animation(.spring(), value: filled)
            }
            
            VStack {
                Divider().background(.primary)
                ZStack {
                    if self.content.isEmpty {
                        TextEditor(text: $placeholder)
                            .padding(.leading, required ? 4 : 0)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    TextEditor(text: $content)
                        .padding(.leading, required ? 4 : 0)
                        .opacity(self.content.isEmpty ? 0.4 : 1)
                        .font(.system(size: 14))
                }
                Divider().background(.primary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 120)
        .padding(.horizontal)
    }
}

struct SportHashtagListView: View {
    @ObservedObject var sportSelectVM: SportSelectViewModel
    var action1: (String) -> ()
    var action2: (String) -> ()
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 30) {
            if sportSelectVM.query == "" {
                ForEach(sportSelectVM.sportList.map { $0.key }, id: \.self) { key in
                    Button(action: { action1(key) }) {
                        SportSelectItem(text: key, selected: sportSelectVM.sportList[key]!)
                    }
                }
            } else {
                if sportSelectVM.newSportList.isEmpty {
                    Spacer()
                    Button {
                        sportSelectVM.userHashtag.append("#\(sportSelectVM.query)")
                        sportSelectVM.selectedSport.append("#\(sportSelectVM.query)")
                        sportSelectVM.query = ""
                    } label: {
                        Text(StringResources.add)
                            .font(.body)
                    }
                } else {
                    ForEach(sportSelectVM.newSportList.map { $0.key }, id: \.self) { key in
                        Button(action: { action2(key) }) {
                            SportSelectItem(text: key, selected: sportSelectVM.newSportList[key]!)
                        }
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 1, leading: 20, bottom: 1, trailing: 20))
    }
}

struct PlacesBottomSheet: View {
    @Binding var customSheetBgPresented: Bool
    @Binding var customSheetOffset: CGFloat
    @ObservedObject var postVM: PostViewModel
    
    @State var setLocation = false
    @State var locationToDelete = ""
    @State var alert = false
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                Rectangle()
                    .fill(.white)
                    .frame(height: 10)
                           
                ForEach(postVM.locationList.indices, id: \.self) { i in
                    HStack {
                        Button(action: {
                            postVM.changeCurrentLocation(location: postVM.locationList[i]) {
                                withAnimation(.easeIn) {
                                    customSheetOffset = 200
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    customSheetBgPresented = false
                                }
                            }
                        }) {
                            Text(String(postVM.locationList[i].split(separator: " ").last!))
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Rectangle()
                                .foregroundColor(.secondary)
                                .frame(width: 1, height: 15)
                            
                            Text(postVM.locationList[i])
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if postVM.currentLocation == postVM.locationList[i] {
                                Circle()
                                    .fill(Color("moare"))
                                    .frame(width: 10, height: 10)
                            }
                            
                            Spacer()
                        }
                        
                        Button(action: {
                            self.locationToDelete = postVM.locationList[i]
                            self.alert = true
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    if i != postVM.locationList.count - 1 {
                        Rectangle()
                            .fill(.gray)
                            .frame(height: 1)
                    }
                }
                
                Spacer()
                Button(action: {
                    self.setLocation = true
                }) {
                    Text(StringResources.changeLocation)
                        .font(.body)
                        .padding(.bottom, 14)
                }
            } // vstack
            .background(.white)
            .frame(maxWidth: .infinity, maxHeight: 200)
            .cornerRadius(20)
            .offset(y: customSheetOffset)
        } // vstack
        .ignoresSafeArea()
        .alert(isPresented: $alert) {
            Alert(
                title: Text(StringResources.deleteLocation),
                message: Text(self.locationToDelete + StringResources.confirmToDeleteLocation),
                primaryButton: .destructive(Text(StringResources.cancel)),
                secondaryButton: .cancel(Text(StringResources.confirm), action: {
                    self.deleteLocation(location: self.locationToDelete)
                })
            )
        }
        .fullScreenCover(isPresented: $setLocation, onDismiss: {}, content: {
            FindLocationView(setDefault: true, completion: {
                customSheetOffset = 200
                customSheetBgPresented = false
            })
        })
    }
    
    private func deleteLocation(location: String) {
        var locationList = UserDefaults.standard.stringArray(forKey: "locationList") ?? [String]()
        
        for (i, item) in locationList.enumerated() {
            let decoded = UserDefaultLocation.decode(responseString: item)
            
            if decoded.address == location {
                locationList.remove(at: i)
                
                if locationList.isEmpty {
                    postVM.currentLocation = ""
                } else if location == postVM.currentLocation {
                    postVM.currentLocation = UserDefaultLocation.decode(responseString: locationList.first ?? "").address
                }
                
                break
            }
        }
        
        UserDefaults.standard.set(locationList, forKey: "locationList")
        
        withAnimation(.easeIn) {
            customSheetOffset = 200
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            customSheetBgPresented = false
        }
    }
}

struct ToastAlert: View {
    @Binding var toastAlert: Bool
    @Binding var toastAlertOffset: CGFloat
    var text: String
    var offsetY: CGFloat = 100
    
    var body: some View {
        VStack {
            Spacer()
            
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .padding(.horizontal)
                .frame(maxHeight: 40)
                .overlay(
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("moare"), lineWidth: 1)
                            .padding(.horizontal)
                            .frame(maxHeight: 40)
                        
                        Text(text)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                )
                .offset(y: toastAlertOffset)
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                withAnimation(.spring()) {
                    toastAlertOffset = offsetY
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                toastAlert = false
            }
        }
    }
}

struct InfoAlertView: View {
    var text: String = ""
    var offset: CGSize = CGSize(width: 0, height: 0)
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .opacity(0.1)
                .ignoresSafeArea()
            
            VStack {
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(8)
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.secondary, lineWidth: 1))
            .shadow(color: .secondary, radius: 3, x: 0, y: 0)
            .offset(offset)
        }
    }
}

struct CustomNavigationBackButton: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.black)
            .opacity(0.2)
            .frame(width: 30, height: 30)
            .overlay {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
    }
}
