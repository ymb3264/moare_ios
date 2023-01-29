//
//  CustomChannelHeader.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import StreamChatSwiftUI

public struct CustomChannelHeader: ToolbarContent {
    @Injected(\.fonts) var fonts
    @Injected(\.images) var images
    
    public var title: String
    public var goBack: () -> ()
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(StringResources.message)
                .font(fonts.bodyBold)
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { goBack() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color("moare"))
            }
        }
    }
}
