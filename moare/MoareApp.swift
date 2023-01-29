//
//  moareApp.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

@main
struct MoareApp: App {
    @StateObject var appState = AppState.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            if appState.showMain {
                MainView()
            } else {
                StartView()
            }
        }
    }
}
