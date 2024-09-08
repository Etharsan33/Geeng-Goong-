//
//  ChatBotMessage.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 07/12/2021.
//

import Foundation
import UIKit

struct ChatBotMessage: ChatMessage {
    
    static let CHAT_BOT_ID = "CHAT_BOT_ID"
    static let CHAT_BOT_DISPLAY_NAME = "CHAT_BOT_DISPLAY_NAME"

    struct ChatBotUser: SenderType {
        var senderId: String
        var displayName: String
    }
    
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    private var bot: ChatBotUser
    var sender: SenderType {
        return bot
    }

    init(message: String, messageId: String, date: Date) {
        self.kind = .attributedText(NSAttributedString(string: message, attributes: [.font : UIFont.gv_body1().semibolded]))
        self.messageId = messageId
        self.sentDate = date
        self.bot = .init(senderId: Self.CHAT_BOT_ID,
                         displayName: Self.CHAT_BOT_DISPLAY_NAME)
    }
}
