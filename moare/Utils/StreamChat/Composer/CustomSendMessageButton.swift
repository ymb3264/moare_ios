//
//  CustomSendMessageButton.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import StreamChatSwiftUI

struct CustomSendMessageButton: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    
    var enabled: Bool
    var onTap: () -> Void
    
    public init(enabled: Bool, onTap: @escaping () -> Void) {
        self.enabled = enabled
        self.onTap = onTap
    }
    
    public var body: some View {
        Button {
            onTap()
        } label: {
            Image(uiImage: images.sendArrow)
                .renderingMode(.template)
                .rotationEffect(enabled ? Angle(degrees: -90) : .zero)
                .foregroundColor(
                    Color(
                        enabled ? UIColor(Color("moare")) : colors.disabledColorForColor(enabledBackground)
                    )
                )
        }
        .disabled(!enabled)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("SendMessageButton")
    }
    
    private var enabledBackground: UIColor {
        colors.highlightedAccentBackground
    }
}
