//
//  CustomSlowModeView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import UIKit
import StreamChatSwiftUI

struct CustomSlowModeView: View {
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    private let size: CGFloat = 32
    
    var cooldownDuration: Int
    
    public var body: some View {
        Text("\(cooldownDuration)")
            .padding(.horizontal, 8)
            .font(fonts.bodyBold)
            .frame(width: cooldownDuration < 10 ? size : nil, height: size)
            .background(
                Color(
                    colors.disabledColorForColor(colors.highlightedAccentBackground)
                )
            )
            .foregroundColor(Color(colors.textInverted))
            .clipShape(Capsule())
            .padding(.bottom, 2)
            .accessibilityIdentifier("SlowModeView")
    }
}
