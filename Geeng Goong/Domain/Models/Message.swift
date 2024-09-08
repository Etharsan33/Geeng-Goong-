//
//  Message.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 27/11/2021.
//

import Foundation

struct Message: Equatable {
    let id: String
    let text: String
    let timestampMs: Double
    let type: ChatMessageType
    let user: User
    var status: MessageStatus
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.timestampMs == rhs.timestampMs &&
        lhs.type == rhs.type &&
        lhs.user == rhs.user
    }
}
