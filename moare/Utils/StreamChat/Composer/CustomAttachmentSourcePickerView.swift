//
//  CustomAttachmentSourcePickerView.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import StreamChatSwiftUI

public struct CustomAttachmentSourcePickerView: View {
    
    @Injected(\.colors) private var colors
    @Injected(\.images) private var images
    
    var selected: AttachmentPickerState
    var onTap: (AttachmentPickerState) -> Void
    
    public init(
        selected: AttachmentPickerState,
        onTap: @escaping (AttachmentPickerState) -> Void
    ) {
        self.selected = selected
        self.onTap = onTap
    }
    
    public var body: some View {
        
        HStack(alignment: .center, spacing: 24) {
            CustomAttachmentPickerButton(
                icon: images.attachmentPickerPhotos,
                pickerType: .photos,
                isSelected: selected == .photos,
                onTap: onTap
            )
            .accessibilityIdentifier("attachmentPickerPhotos")
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color(colors.background1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AttachmentSourcePickerView")
    }
}

public struct CustomAttachmentPickerButton: View {
    @Injected(\.colors) private var colors
    
    var icon: UIImage
    var pickerType: AttachmentPickerState
    var isSelected: Bool
    var onTap: (AttachmentPickerState) -> Void
    
    public init(
        icon: UIImage,
        pickerType: AttachmentPickerState,
        isSelected: Bool,
        onTap: @escaping (AttachmentPickerState) -> Void
    ) {
        self.icon = icon
        self.pickerType = pickerType
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    public var body: some View {
        Button {
            onTap(pickerType)
        } label: {
            Image(uiImage: icon)
                .customizable()
                .frame(width: 22)
                .foregroundColor(
                    isSelected ? Color("moare")
                        : Color(colors.textLowEmphasis)
                )
        }
    }
}
