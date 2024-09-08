//
//  GameAction.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 07/12/2021.
//

import Foundation

enum GameAction {
    case startGame, postRound
    
    var chatBotDataView: ChatBotDataView {
        switch self {
        case .startGame:
            return .init(title: "On commence ?",
                         leftButtonType: .init(title: "Pas le temps", type: .simple),
                         rightButtonType: .init(title: "Chaud !!", type: .default))
        case .postRound:
            return .init(title: "A vous de jouer",
                         leftButtonType: .init(title: "Ping", type: .default),
                         rightButtonType: .init(title: "Pong", type: .default))
        }
    }
    
    var gameListMessage: String {
        switch self {
        case .startGame:
            return "A toi de valider"
        case .postRound:
            return "A toi de jouer"
        }
    }
}
