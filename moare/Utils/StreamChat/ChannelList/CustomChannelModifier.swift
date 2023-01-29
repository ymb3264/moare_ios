//
//  CustomChannelModifier.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import StreamChatSwiftUI

struct CustomChannelModifier: ChannelListHeaderViewModifier {

    var title: String
    @Environment(\.presentationMode) var presentationMode

    func body(content: Content) -> some View {
        content
            .navigationBarHidden(true)
            .toolbar {
            CustomChannelHeader(title: title) {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("")
    }

}
