//
//  GameSocketResponse.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 29/11/2021.
//

import Foundation

struct GameSocketResponse: Decodable {
    enum Action: String, Decodable {
        case startGame, postRound
    }
    
    let id: String
    let creationDateMs: Double
    let lastActionDateMs: Double
    let action: Action?
    let unreadMessageCount: Int?
    let opponent: UserSocketResponse
}

// MARK: - To Domain
extension GameSocketResponse {
    
    func toDomain() -> Game {
        func getAction() -> GameAction? {
            switch self.action {
            case .postRound: return .postRound
            case .startGame: return .startGame
            case .none: return .none
            }
        }
        
        return .init(id: self.id,
                     creationDateMs: self.creationDateMs,
                     lastActionDateMs: self.lastActionDateMs,
                     action: getAction(),
                     unreadMessageCount: self.unreadMessageCount ?? 0,
                     opponent: self.opponent.toDomain())
    }
}
