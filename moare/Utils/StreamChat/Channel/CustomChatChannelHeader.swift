//
//  CustomChatChannelHeader.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct CustomChatChannelHeader: ToolbarContent {
    @Injected(\.fonts) private var fonts
    @Injected(\.utils) private var utils
    @Injected(\.chatClient) private var chatClient
    
    public var channel: ChatChannel
    public var headerImage: UIImage
    
    private var currentUserId: String {
        chatClient.currentUserId ?? ""
    }
    
    private var channelNamer: ChatChannelNamer {
        utils.channelNamer
    }
    
    public init(
        channel: ChatChannel,
        headerImage: UIImage
    ) {
        self.channel = channel
        self.headerImage = headerImage
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement:.principal) {
            HStack {
                ChannelAvatarView(
                    avatar: headerImage,
                    showOnlineIndicator: false,
                    size: CGSize(width: 36, height: 36)
                )
                .allowsHitTesting(false)
                
                Text(channelNamer(channel, currentUserId) ?? "")
                    .font(fonts.bodyBold)
                    .accessibilityIdentifier("chatName")
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            EmptyView()
        }
    }
}
