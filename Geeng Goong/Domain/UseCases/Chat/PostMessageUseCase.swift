//
//  PostMessageUseCase.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 30/12/2021.
//

import Foundation
import RxSwift

protocol PostMessageUseCase {
    func sendNewMessage(gameId: String, message: Message, completion: @escaping (Message) -> Void)
    func messagePosted(completion: @escaping (Message) -> Void)
}

class DefaultPostMessageUseCase: PostMessageUseCase {
    
    private let gameChatRepository: GameChatRepository
    private let persistenceService: PersistenceCoreDataService
    
    init(gameChatRepository: GameChatRepository,
         persistenceService: PersistenceCoreDataService) {
        self.gameChatRepository = gameChatRepository
        self.persistenceService = persistenceService
    }
    
    func sendNewMessage(gameId: String, message: Message,
                        completion: @escaping (Message) -> Void) {
        self.gameChatRepository.sendNewMessage(
            msg: message.text,
            creationDateMs: message.timestampMs) { [weak self] result in
                switch result {
                case .success(let message):
                    completion(message.toDomain())
                case .failure:
                    var messageNotSend = message
                    messageNotSend.status = .couldNotSend
                    self?.insertMessage(messageNotSend, gameId: gameId)
                    completion(messageNotSend)
                }
        }
    }
    
    func messagePosted(completion: @escaping (Message) -> Void) {
        self.gameChatRepository.onMessagePosted { message in
            completion(message.toDomain())
        }
    }
    
    // MARK: - Private
    private func insertMessage(_ message: Message, gameId: String) {
        self.persistenceService.addNewItem(completionInsert: { context in
            
            let localUser = LocalUser(context: context,
                                      id: message.user.id,
                                      userName: message.user.userName,
                                      avatarType: message.user.avatarType)
            
            _ = LocalMessage(context: context,
                             id: message.id,
                             text: message.text,
                             creationDateMs: message.timestampMs,
                             type: message.type,
                             gameId: gameId,
                             status: message.status,
                             localUser: localUser)
            
        }, completion: nil)
    }
}
