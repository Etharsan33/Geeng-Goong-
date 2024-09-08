//
//  ChatSystemMessage.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 08/12/2021.
//

import Foundation

struct ChatSystemMessage: ChatMessage {

    static let CHAT_SYSTEM_ID = "CHAT_SYSTEM_ID"
    static let CHAT_SYSTEM_DISPLAY_NAME = "CHAT_SYSTEM_DISPLAY_NAME"
    
    struct ChatUser: SenderType {
        var senderId: String
        var displayName: String
    }
    
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    let gameAction: GameAction
    
    private var user: ChatUser
    var sender: SenderType {
        return user
    }

    init(messageId: String, date: Date, gameAction: GameAction) {
        self.kind = .custom(nil)
        self.messageId = messageId
        self.sentDate = date
        self.gameAction = gameAction
        self.user = .init(senderId: Self.CHAT_SYSTEM_ID,
                          displayName: Self.CHAT_SYSTEM_DISPLAY_NAME)
    }
}
