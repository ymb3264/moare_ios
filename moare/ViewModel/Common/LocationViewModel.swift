//
//  LocationViewModel.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI

class LocationViewModel: ObservableObject {
    private let api = LocationAPI()
    
    @Published var query = ""
    @Published var addressItems = [AddressItem]()
    
    @Published var errorText = false
    @Published var loading = false
    @Published var networkError = false
    
    private var addressArr = AddressResponse(documents: [])
    
    @MainActor func searchAddress() {
        self.loading = true
        Task {
            do {
                self.addressArr = try await api.searchAddress(query: query)
                addressItems.removeAll()
                
                addressArr.documents.forEach { item in
                    var addressItem = AddressItem(address: "", x: item.x, y: item.y)
                    
                    if let address = item.generalAddress {
                        if !address.address3.isEmpty || !address.address3_h.isEmpty {
                            addressItem.address += address.address1 + " "
                            addressItem.address += address.address2 + " "
                            addressItem.address += address.address3.isEmpty ? address.address3_h + " " : address.address3 + " "
                        } else {
                            self.loading = false
                            errorText = true
                            return
                        }
                        self.addressItems.append(addressItem)
                    }
                }
                self.loading = false
            } catch {
                if let networkError = error as? NetworkError {
                    switch networkError.error {
                    case .requestError:
                        self.loading = false
                        self.networkError = true
                    case .serverError:
                        self.loading = false
                        self.networkError = true
                    default:
                        self.loading = false
                        self.networkError = true
                    }
                } else {
                    self.loading = false
                    self.networkError = true
                    print("\(error)")
                }
            }
        }
    }
    
    func searchCoordinateAddress(x: String, y: String) async -> AddressItem {
        let coordinate = Coordinate(x: x, y: y)
        
        do {
            let response = try await api.searchCoordinateAddress(coordinate: coordinate)
            
            let address = response.documents[0].generalAddress
            var addressItem = AddressItem(address: "", x: x, y: y)
            
            if let address = address {
                addressItem.address += address.address1 + " "
                addressItem.address += address.address2 + " "
                addressItem.address += address.address3 + " "
            }
            
            return addressItem
        } catch {
            // toast alert 추가
            return AddressItem(address: "", x: "", y: "")
        }
    }
    
    func setUserDefaultLocation(addressItem: AddressItem, completion: @escaping () -> ()) {
        var locationList = UserDefaults.standard.stringArray(forKey: "locationList") ?? [String]()
        let location = UserDefaultLocation(address: addressItem.address, x: addressItem.x , y: addressItem.y)
        
        if !locationList.contains(location.encoded()) {
            locationList.append(location.encoded())
            UserDefaults.standard.set(locationList, forKey: "locationList")
        }
        
        UserDefaults.standard.set(location.address, forKey: "currentLocation")
        completion()
    }
}
