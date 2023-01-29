//
//  CustomChatChannelModifier.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct CustomChatChannelModifier: ChatChannelHeaderViewModifier {
    @StateObject private var channelHeaderLoader = ChannelHeaderLoader()
    var channel: ChatChannel
    
    func body(content: Content) -> some View {
        content.toolbar {
            CustomChatChannelHeader(
                channel: channel,
                headerImage: channelHeaderLoader.image(for: channel)
            )
        }
    }
}
