//
//  LocationManager.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    
    @ObservedObject var locationVM = LocationViewModel()
    @Published var addressItem = AddressItem(address: "", x: "", y: "")
    @Published var alert = false
    @Published var locationAlertState: LocationAlertState = .currentLocation
    @Published var askPermission = false
    @Published var loading = false
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestLocation(permissionAlert: () -> ()) {
        if manager.authorizationStatus == .denied {
            permissionAlert()
        } else if manager.authorizationStatus == .authorizedWhenInUse {
            self.loading = true
            if let location = location {
                Task {
                    self.addressItem = await locationVM.searchCoordinateAddress(x: "\(location.longitude)", y: "\(location.latitude)")
                    self.loading = false
                    self.locationAlertState = .currentLocation
                    self.alert = true
                }
            }
        } else {
            askPermission = true
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        
        if askPermission {
            self.loading = true
            if let location = location {
                Task {
                    self.addressItem = await self.locationVM.searchCoordinateAddress(x: "\(location.longitude)", y: "\(location.latitude)")
                    self.loading = false
                    self.locationAlertState = .currentLocation
                    self.alert = true
                }
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        manager.startUpdatingLocation()
    }
}
