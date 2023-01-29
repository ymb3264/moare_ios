//
//  CustomTrailingSwipeActionsView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import StreamChatSwiftUI
import StreamChat

public struct CustomTrailingSwipeActionsView: View {
    
    @Injected(\.colors) private var colors
    
    var channel: ChatChannel
    var offsetX: CGFloat
    var buttonWidth: CGFloat
    
    public var body: some View {
        HStack {
            Spacer()
            ZStack {
                HStack(spacing: 0) {
                    ActionItemButton(imageName: "trash", action: {
                        withAnimation {
                            AppState.shared.channelDeleteAlert = true
                            AppState.shared.isDirectMessage = channel.isDirectMessageChannel
                            AppState.shared.channelId = channel.cid
                        }
                    })
                    .frame(width: buttonWidth)
                    .foregroundColor(Color(colors.textInverted))
                    .background(Color(colors.alert))
                }
            }
            .opacity(self.offsetX < -5 ? 1 : 0)
        }
        .accessibilityIdentifier("TrailingSwipeActionsView")
    }
}
