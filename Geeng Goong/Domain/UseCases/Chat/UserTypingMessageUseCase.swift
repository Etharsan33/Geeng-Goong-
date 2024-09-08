//
//  UserTypingMessageUseCase.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 30/12/2021.
//

import Foundation
import RxSwift

protocol UserTypingMessageUseCase {
    func startTyping()
    func stopTyping()
    func userIsTyping(completion: @escaping (Bool) -> Void)
}

class DefaultUserTypingMessageUseCase: UserTypingMessageUseCase {
    
    private let gameChatRepository: GameChatRepository
    
    init(gameChatRepository: GameChatRepository) {
        self.gameChatRepository = gameChatRepository
    }
    
    func startTyping() {
        self.gameChatRepository.startTyping()
    }
    
    func stopTyping() {
        self.gameChatRepository.stopTyping()
    }
    
    func userIsTyping(completion: @escaping (Bool) -> Void) {
        self.gameChatRepository.onUserIsTyping { isTyping in
            completion(isTyping)
        }
    }
}
