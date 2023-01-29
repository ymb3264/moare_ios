//
//  CustomLeadingComposerView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import StreamChat
import SwiftUI
import StreamChatSwiftUI

public struct CustomLeadingComposerView: View {
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    
    @Binding var pickerTypeState: PickerTypeState
    var channelConfig: ChannelConfig?
    
    public init(
        pickerTypeState: Binding<PickerTypeState>,
        channelConfig: ChannelConfig?
    ) {
        _pickerTypeState = pickerTypeState
        self.channelConfig = channelConfig
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            switch pickerTypeState {
            case let .expanded(attachmentPickerType):
                if channelConfig?.uploadsEnabled == true {
                    PickerTypeButton(
                        pickerTypeState: $pickerTypeState,
                        pickerType: .media,
                        selected: attachmentPickerType
                    )
                    .accessibilityIdentifier("PickerTypeButtonMedia")
                }
            case .collapsed:
                Button {
                    withAnimation {
                        pickerTypeState = .expanded(.none)
                    }
                } label: {
                    Image(uiImage: images.shrinkInputArrow)
                        .renderingMode(.template)
                        .foregroundColor(Color("moare"))
                }
                .accessibilityIdentifier("PickerTypeButtonCollapsed")
            }
        }
        .padding(.bottom, 8)
        .accessibilityElement(children: .contain)
    }
}

struct PickerTypeButton: View {
    @Injected(\.colors) private var colors
    
    @Binding var pickerTypeState: PickerTypeState
    
    let pickerType: AttachmentPickerType
    let selected: AttachmentPickerType
    
    var body: some View {
        Button {
            withAnimation {
                onTap(attachmentType: pickerType, selected: selected)
            }
        } label: {
            Image(systemName: "photo")
                .renderingMode(.template)
                .aspectRatio(contentMode: .fill)
                .frame(height: 18)
                .foregroundColor(
                    foregroundColor(for: pickerType, selected: selected)
                )
        }
    }
    
    private func onTap(
        attachmentType: AttachmentPickerType,
        selected: AttachmentPickerType
    ) {
        if selected == attachmentType {
            pickerTypeState = .expanded(.none)
        } else {
            pickerTypeState = .expanded(attachmentType)
        }
    }
    
    private func foregroundColor(
        for pickerType: AttachmentPickerType,
        selected: AttachmentPickerType
    ) -> Color {
        if pickerType == selected {
            return Color("moare")
        } else {
            return Color(colors.textLowEmphasis)
        }
    }
}
