//
//  LocalMessage.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 20/12/2021.
//

import Foundation
import CoreData

class LocalMessage: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, id: String, text: String, creationDateMs: Double, type: ChatMessageType, gameId: String, status: MessageStatus, localUser: LocalUser) {
        
        self.init(context: context)
        
        self.id = id
        self.text = text
        self.creationDateMs = creationDateMs
        self.type = type.rawValue
        self.gameId = gameId
        self.status = status.rawValue
        self.user = localUser
    }
}

// MARK: - To Domain
extension LocalMessage {
    
    func toDomain() -> Message? {
        guard let id = self.id,
              let text = self.text,
              let user = self.user,
              let status = self.status,
              let messageStatus = MessageStatus(rawValue: status) else {
                  return nil
              }
        
        func getChatType() -> ChatMessageType {
            guard let type = self.type,
                  let chatType = ChatMessageType(rawValue: type) else {
                      return .user
                  }
            return chatType
        }
        
        return .init(id: id,
                     text: text,
                     timestampMs: self.creationDateMs,
                     type: getChatType(),
                     user: user.toDomain(),
                     status: messageStatus)
    }
}
