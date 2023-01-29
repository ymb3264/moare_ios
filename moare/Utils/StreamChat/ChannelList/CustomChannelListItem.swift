//
//  CustomChannelListItem.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import NukeUI
import StreamChat

struct CustomChannelListItem: View {
    let channel: ChatChannel
    let channelName: String
    let avatar: UIImage
    let lastMessageAt: String
    
    init(channel: ChatChannel, channelName: String, avatar: UIImage) {
        self.channel = channel
        self.channelName = channelName
        self.avatar = avatar
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a hh:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        lastMessageAt = dateFormatter.string(from: channel.lastMessageAt ?? Date())
    }
    
    var body: some View {
        HStack {
            Image(uiImage: avatar)
                .resizable()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .aspectRatio(contentMode: .fit)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(channelName)
                    .font(.body)
                Text(channel.lastMessageText ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Circle()
                    .fill(.red)
                    .frame(width: 18, height: 18)
                    .overlay {
                        Text("\(channel.unreadCount.messages)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                
                Text(lastMessageAt)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
}
