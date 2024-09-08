//
//  ChatLoadingMessage.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 21/02/2022.
//

import Foundation

struct ChatLoadingMessage: ChatMessage {

    struct SenderUser: SenderType {
        var senderId: String
        var displayName: String = ""
    }
    
    var user: SenderUser
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    var sender: SenderType {
        return self.user
    }

    init(senderId: String) {
        self.kind = .custom(nil)
        self.messageId = UUID().uuidString
        self.sentDate = Date()
        self.user = .init(senderId: senderId)
    }
}

