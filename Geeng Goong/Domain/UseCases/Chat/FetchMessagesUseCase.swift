//
//  FetchMessagesUseCase.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 21/12/2021.
//

import Foundation
import RxSwift

protocol FetchMessagesUseCase {
    func execute(gameID: String, limit: Int, offset: Int, completion: @escaping ([Message]) -> Void)
}

class DefaultFetchMessagesUseCase: FetchMessagesUseCase {
    
    private let repository: GameChatRepository
    private let persistenceService: PersistenceCoreDataService
    
    init(repository: GameChatRepository, persistenceService: PersistenceCoreDataService) {
        self.repository = repository
        self.persistenceService = persistenceService
    }
    
    func execute(gameID: String, limit: Int, offset: Int, completion: @escaping ([Message]) -> Void) {
        let predicate = NSPredicate(format: "gameId == %@", gameID)
        let sort = NSSortDescriptor(keyPath: \LocalMessage.creationDateMs, ascending: false)
        
        func getRemoteData(messagesInLocal: [Message]) {
            self.repository.onGetMessages { [weak self] socketMessages in
                let messages = socketMessages.map { $0.toDomain() }
                
                if messagesInLocal != messages {
                    self?.persistenceService.deleteItems(
                        entity: LocalMessage.self,
                        predicate: predicate,
                        range: (limit, offset * limit),
                        sortDescriptors: [sort]) { [weak self] error in
                        if error == nil {
                            self?.insertMessages(socketMessages)
                        }
                    }
                }
                
                completion(messages)
            }
        }
        
        self.persistenceService.fetchItems(
            entity: LocalMessage.self,
            predicate: predicate,
            range: (limit, offset * limit),
            sortDescriptors: [sort]) { result in
                switch result {
                case .success(let localMessages):
                    let messages = localMessages
                        .sorted(by: {$0.creationDateMs < $1.creationDateMs})
                        .compactMap { $0.toDomain() }
                    
                    getRemoteData(messagesInLocal: messages)
                    completion(messages)
                case .failure:
                    getRemoteData(messagesInLocal: [])
                }
        }
    }
    
    private func insertMessages(_ messages: [MessageSocketResponse]) {
        self.persistenceService.insertItems(completionItems: { context in
            let localMessages = messages.map { message -> LocalMessage in
                let localUser = LocalUser(context: context,
                                          id: message.user.id,
                                          userName: message.user.userName,
                                          avatarType: message.user.avatarColor)
                
                let localMessage = LocalMessage(context: context,
                                                id: message.id,
                                                text: message.text,
                                                creationDateMs: message.creationDateMs,
                                                type: message.type,
                                                gameId: message.gameId,
                                                status: .delivered,
                                                localUser: localUser)
                return localMessage
            }
            return localMessages
        }, entity: LocalMessage.entity(), completion: nil)
    }
}