//
//  MessageSocketResponse.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 27/11/2021.
//

import Foundation

struct MessageSocketResponse: Decodable {
    let id: String
    let type: ChatMessageType
    let text: String
    let user: UserSocketResponse
    let creationDateMs: Double
    let gameId: String
}

// MARK: - To Domain
extension MessageSocketResponse {
    
    func toDomain() -> Message {
        return .init(id: self.id,
                     text: self.text,
                     timestampMs: self.creationDateMs,
                     type: self.type,
                     user: self.user.toDomain(),
                     status: .delivered)
    }
}
