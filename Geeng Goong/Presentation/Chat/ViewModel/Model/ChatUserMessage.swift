//
//  ChatUserMessage.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 07/12/2021.
//

import Foundation
import UIKit

struct ChatUserMessage: ChatMessage {

    struct ChatUser: SenderType {
        let avatarType: AvatarType
        var senderId: String
        var displayName: String
    }
    
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var status: MessageStatus
    
    private var user: ChatUser
    var sender: SenderType {
        return user
    }

    init(message: String, user: ChatUser, messageId: String, date: Date, status: MessageStatus) {
        self.kind = .attributedText(NSAttributedString(string: message, attributes: [.font : UIFont.gv_body1().semibolded]))
        self.user = user
        self.messageId = messageId
        self.sentDate = date
        self.status = status
    }
}
