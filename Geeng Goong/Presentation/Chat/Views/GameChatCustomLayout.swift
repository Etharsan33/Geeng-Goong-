//
//  GameChatCustomLayout.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 02/02/2022.
//

import UIKit

final class SystemMessageSizeCalculator: MessageSizeCalculator {
    override func messageContainerSize(for message: MessageType) -> CGSize {
        return CGSize(width: 300, height: 122)
    }
}

final class LoadingMessageSizeCalculator: MessageSizeCalculator {
    override func messageContainerSize(for message: MessageType) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: ChatLoadingMessageViewCell.preferredHeight)
    }
}

final class RetryTextMessageSizeCalculator: TextMessageSizeCalculator {
    private let AVATAR_SIZE: CGFloat = 32
    
    override func avatarSize(for message: MessageType) -> CGSize {
        return .init(width: AVATAR_SIZE, height: AVATAR_SIZE)
    }
    
    override func avatarPosition(for message: MessageType) -> AvatarPosition {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        
        return .init(horizontal: isFromCurrentSender ? .cellTrailing : .cellLeading, vertical: .messageBottom)
    }
    
    override func messageLabelInsets(for message: MessageType) -> UIEdgeInsets {
        return .init(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    override func cellBottomLabelAlignment(for message: MessageType) -> LabelAlignment {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return .init(textAlignment: isFromCurrentSender ? .right : .left, textInsets: .init(top: 0, left: isFromCurrentSender ? 0 : AVATAR_SIZE + 4, bottom: 0, right: isFromCurrentSender ? AVATAR_SIZE + 4 : 0))
    }
}

// MARK: - Layout
final class GameChatFlowLayout: MessagesCollectionViewFlowLayout {
    lazy var systemMessageSize = SystemMessageSizeCalculator(layout: self)
    lazy var retryTextMessageSize = RetryTextMessageSizeCalculator(layout: self)
    lazy var loadingMessageSize = LoadingMessageSizeCalculator(layout: self)

    override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        //before checking the messages check if section is reserved for typing otherwise it will cause IndexOutOfBounds error
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return typingIndicatorSizeCalculator
        }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind, message is ChatSystemMessage {
            return self.systemMessageSize
        }
        if case .custom = message.kind, message is ChatLoadingMessage {
            return self.loadingMessageSize
        }
        if let userMsg = message as? ChatUserMessage,
            userMsg.status == .couldNotSend,
            messagesDataSource.isFromCurrentSender(message: message) {
            return self.retryTextMessageSize
        }
        return super.cellSizeCalculatorForItem(at: indexPath)
    }
}
