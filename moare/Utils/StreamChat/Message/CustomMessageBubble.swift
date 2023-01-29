//
//  CustomMessageBubble.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct CustomMessageBubble: View {
    
    let message: ChatMessage
    let isFirst: Bool
    
    var body: some View {
        if message.isSentByCurrentUser {
            ZStack(alignment: .topTrailing) {
                Text(message.text)
                    .font(.body)
                    .padding(.trailing, 8)
                    .padding(.vertical, 6)
                
                VStack(alignment: .trailing, spacing: 0) {
                    HStack {
                        Rectangle()
                            .fill(Color("moare"))
                            .frame(width: 8, height: 2)
                    }
                    
                    HStack {
                        Rectangle()
                            .fill(Color("moare"))
                            .frame(width: 2, height: 8)
                    }
                }
            }
        } else {
            VStack {
                ZStack(alignment: .topLeading) {
                    Text(message.text)
                        .font(.body)
                        .padding(.leading, 8)
                        .padding(.vertical, 6)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Rectangle()
                                .fill(.secondary)
                                .frame(width: 8, height: 2)
                        }
                        
                        HStack {
                            Rectangle()
                                .fill(.secondary)
                                .frame(width: 2, height: 8)
                        }
                    } // vstack
                } // zstack
            } // vstack
        }
    }
}
