//
//  GameRoundPostUseCase.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 30/12/2021.
//

import Foundation
import RxSwift

protocol GameRoundPostUseCase {
    func post(type: RoundType)
    func roundPosted(completion: @escaping (Game) -> Void)
}

class DefaultGameRoundPostUseCase: GameRoundPostUseCase {
    
    private let gameChatRepository: GameChatRepository
    
    init(gameChatRepository: GameChatRepository) {
        self.gameChatRepository = gameChatRepository
    }
    
    func post(type: RoundType) {
        self.gameChatRepository.roundPost(roundType: type)
    }
    
    func roundPosted(completion: @escaping (Game) -> Void) {
        self.gameChatRepository.onRoundPosted { game in
            completion(game.toDomain())
        }
    }
}
