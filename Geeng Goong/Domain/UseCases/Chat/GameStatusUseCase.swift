//
//  GameStatusUseCase.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 30/12/2021.
//

import Foundation
import RxSwift

protocol GameStatusUseCase {
    func joinGame()
    func startGame(completion: @escaping (Game) -> Void)
    func declineGame(completion: @escaping (Bool) -> Void)
    
    func gameStarted(completion: @escaping (Game) -> Void)
}

class DefaultGameStatusUseCase: GameStatusUseCase {
    
    private let gameChatRepository: GameChatRepository
    
    init(gameChatRepository: GameChatRepository) {
        self.gameChatRepository = gameChatRepository
    }
    
    func joinGame() {
        self.gameChatRepository.joinGame()
    }
    
    func startGame(completion: @escaping (Game) -> Void) {
        self.gameChatRepository.startGame { game in
            completion(game.toDomain())
        }
    }
    
    func declineGame(completion: @escaping (Bool) -> Void) {
        self.gameChatRepository.declineGame { isDeclined in
            completion(isDeclined)
        }
    }
    
    func gameStarted(completion: @escaping (Game) -> Void) {
        self.gameChatRepository.onGameStarted { game in
            completion(game.toDomain())
        }
    }
}
