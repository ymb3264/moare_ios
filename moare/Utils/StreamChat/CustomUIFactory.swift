//
//  CustomUIFactory.swift
//  moare
//
//  Created by Mobul Yoon on 2023/01/10.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

class CustomUIFactory: ViewFactory, ObservableObject {
    @Injected(\.chatClient) public var chatClient
    
    private init() {}
    
    public static let shared = CustomUIFactory()

    func makeChannelListHeaderViewModifier(title: String) -> some ChannelListHeaderViewModifier {
        CustomChannelModifier(title: title)
    }
    
    func makeNoChannelsView() -> some View {
        Text(StringResources.noChannelMessage)
            .font(.body)
    }
    
    func makeChannelListTopView(searchText: Binding<String>) -> some View {
        EmptyView()
    }
    
    func makeChannelHeaderViewModifier(for channel: ChatChannel) -> some ChatChannelHeaderViewModifier {
        CustomChatChannelModifier(channel: channel)
    }
    
    func makeMessageListDateIndicator(date: Date) -> some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        let listDate = dateFormatter.string(from: Date())
        
        return CustomMessageListDateIndicator(date: listDate)
    }
    
    func makeLeadingComposerView(state: Binding<PickerTypeState>, channelConfig: ChannelConfig?) -> some View {
        CustomLeadingComposerView(pickerTypeState: state, channelConfig: channelConfig)
    }
    
    func makeTrailingComposerView(enabled: Bool, cooldownDuration: Int, onTap: @escaping () -> Void) -> some View {
        Group {
            if cooldownDuration == 0 {
                CustomSendMessageButton(enabled: enabled, onTap: onTap)
                    .padding(.bottom, 8)
            } else {
                CustomSlowModeView(cooldownDuration: cooldownDuration)
            }
        }
    }
    
    func makeAttachmentSourcePickerView(
        selected: AttachmentPickerState,
        onPickerStateChange: @escaping (AttachmentPickerState) -> Void
    ) -> some View {
        EmptyView()
    }
    
    func makeTrailingSwipeActionsView(
        channel: ChatChannel,
        offsetX: CGFloat,
        buttonWidth: CGFloat,
        swipedChannelId: Binding<String?>,
        leftButtonTapped: @escaping (ChatChannel) -> Void,
        rightButtonTapped: @escaping (ChatChannel) -> Void
    ) -> some View {
        CustomTrailingSwipeActionsView(
            channel: channel,
            offsetX: offsetX,
            buttonWidth: buttonWidth
        )
    }
}
