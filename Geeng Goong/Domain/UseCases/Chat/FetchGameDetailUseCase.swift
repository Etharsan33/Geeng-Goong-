//
//  FetchGameDetailUseCase.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 30/12/2021.
//

import Foundation
import RxSwift

protocol FetchGameDetailUseCase {
    func execute(completion: @escaping (Game) -> Void)
}

class DefaultFetchGameDetailUseCase: FetchGameDetailUseCase {
    
    private let gameChatRepository: GameChatRepository
    
    init(gameChatRepository: GameChatRepository) {
        self.gameChatRepository = gameChatRepository
    }
    
    func execute(completion: @escaping (Game) -> Void) {
        self.gameChatRepository.onGetGameDetail { game in
            completion(game.toDomain())
        }
    }
}
