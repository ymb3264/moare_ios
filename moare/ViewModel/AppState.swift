//
//  AppState.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import KeychainAccess
import StreamChat
import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var selection = TabIdentifier.post
    
    // chat
    @Published var channelDeleteAlert = false
    var channelId = ChannelId(type: .messaging, id: "")
    var isDirectMessage = false
        
    // login / logout
    @Published var showMain = false
    
    // deeplink
    @Published var isDeepLinkActive = false
    @Published var yearAndMonth = ""
    @Published var postCreatedAt = ""
    
    // popToRoot
    @Published var postRootActive = false
    @Published var postSearchBar = false
    @Published var profileRootActive = false
    
    // mainview navigation bar
    @Published var navigationBarHidden = true
    
    @MainActor func logout() {
        do {
            try Keychain().remove("AccessToken")
            try Keychain().remove("RefreshToken")
            selection = TabIdentifier.post
            profileRootActive = false
            showMain = false
        } catch {
            print(error)
        }
    }
}
