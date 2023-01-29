//
//  ContentView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import StreamChat
import StreamChatSwiftUI
import UIKit
import SwiftUI
import KeychainAccess

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var streamChat: StreamChat?
    
    var chatClient: ChatClient = {
        var config = ChatClientConfig(apiKey: .init("rx6c7gawsp4q"))
        config.applicationGroupIdentifier = "group.io.getstream.iOS.ChatDemoAppSwiftUI"
        
        let client = ChatClient(config: config)
        return client
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let messageListConfig = MessageListConfig(
            dateIndicatorPlacement: .messageList,
            messagePopoverEnabled: false
        )
        
        let utils = Utils(messageListConfig: messageListConfig)
        
        streamChat = StreamChat(chatClient: chatClient, utils: utils)
        
        return true
    }
}
