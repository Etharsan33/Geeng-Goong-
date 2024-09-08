//
//  Game.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 29/11/2021.
//

import Foundation

struct Game {
    let id: String
    let creationDateMs: Double
    let lastActionDateMs: Double
    let action: GameAction?
    let unreadMessageCount: Int
    let opponent: User
}
