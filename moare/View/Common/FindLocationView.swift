//
//  FindLocationView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

struct FindLocationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var setDefault = false
    var setPlace: (AddressItem) -> () = {_ in}
    var completion: () -> () = {}
    
    @ObservedObject var locationVM = LocationViewModel()
    @StateObject var locationManager = LocationManager()
    
    @State var alert = false
    
    var body: some View {
        
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        SearchBar(text: $locationVM.query, placeholder: "동명(읍, 면)으로 검색 (ex. 서초동)") {
                            locationVM.searchAddress()
                        }
                        .onChange(of: locationVM.query) { _ in
                            locationVM.errorText = false
                            if locationVM.query.isEmpty {
                                locationVM.addressItems.removeAll()
                            }
                        }
                    }
                    
                    if locationVM.errorText {
                        Text(StringResources.findLocationPlaceholder)
                            .font(.body)
                            .padding(.bottom, 8)
                    }
                    
                    if locationVM.addressItems.isEmpty {
                        Button("현재 위치로 검색") {
                            locationManager.requestLocation {
                                locationManager.locationAlertState = .denied
                                locationManager.alert = true
                            }
                        }
                        .alert(isPresented: $locationManager.alert) {
                            if locationManager.locationAlertState  == .currentLocation {
                                return Alert(
                                    title: Text("\(locationManager.addressItem.address)"),
                                    message: Text(StringResources.confirmToSetLocation),
                                    primaryButton: .destructive(Text(StringResources.cancel)),
                                    secondaryButton: .cancel(Text(StringResources.confirm), action: {
                                        if setDefault {
                                            locationVM.setUserDefaultLocation(addressItem: locationManager.addressItem) {
                                                completion()
                                                presentationMode.wrappedValue.dismiss()
                                            }
                                        } else {
                                            setPlace(locationManager.addressItem)
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    })
                                )
                            } else {
                                return Alert(
                                    title: Text(StringResources.locationPermissionSettingTitle),
                                    message: Text(StringResources.locationPermissionSettingMessage),
                                    primaryButton: .destructive(Text(StringResources.cancel)),
                                    secondaryButton: .cancel(Text(StringResources.confirm), action: {
                                        guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else { return }
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    })
                                )
                            }
                        }
                    }
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            if locationVM.networkError {
                                Text(StringResources.failedToGetAddress)
                                    .font(.body)
                            }
                            if locationVM.loading {
                                ProgressView()
                            }
                            
                            ForEach(locationVM.addressItems) { item in
                                Button(action: {
                                    if setDefault {
                                        alert = true
                                    } else {
                                        setPlace(item)
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }) {
                                    VStack(spacing: 5) {
                                        HStack {
                                            Text(item.address)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .padding(.leading, 10)
                                            
                                            Spacer()
                                        }
                                    }
                                } // button
                                .alert(isPresented: $alert) {
                                    Alert(
                                        title: Text("\(item.address)"),
                                        message: Text(StringResources.confirmToSetLocation),
                                        primaryButton: .destructive(Text(StringResources.cancel)),
                                        secondaryButton: .cancel(Text(StringResources.confirm), action: {
                                            locationVM.setUserDefaultLocation(addressItem: item) {
                                                completion()
                                                presentationMode.wrappedValue.dismiss()
                                            }
                                        })
                                    )
                                }
                            } // foreach
                        } // vstack
                    } // scrollview
                } // vstack
                
                if locationManager.loading {
                    ProgressView()
                }
            } // zstack
            .navigationTitle("지역 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("취소") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        } // navigationview
        .accentColor(Color("moare"))
    } // body
}
