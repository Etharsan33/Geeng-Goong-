//
//  SocketIOGameList.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 29/11/2021.
//

import Foundation
import SocketIO

protocol SocketIOGameList {
    func setUserID(_ userID: String)
    
    func onGetGames(completion: @escaping ([Game]) -> Void)
    func onGameCreated(completion: @escaping (Game) -> Void)
    func onGameDeclined(completion: @escaping (String) -> Void)
    func onGameUnreadMsgUpdated(completion: @escaping (Game) -> Void)
    func onGameRoundPosted(completion: @escaping (Game) -> Void)
    
    func getGamesNext(userId: String, limit: Int, lastGameId: String, completion: @escaping ([Game]) -> Void)
}

class DefaultSocketIOGameList: BaseSocketIO, SocketIOGameList {
    
    private var userID: String?
    
    override func socketConnected() {
        if let userID = userID {
            self.joinRoom(userID: userID)
        }
    }
    
    func setUserID(_ userID: String) {
        self.userID = userID
    }
    
    private func joinRoom(userID: String) {
        socket.emit("userJoin", "games-\(userID)")
    }
    
    func onGetGames(completion: @escaping ([Game]) -> Void) {
        socket.on("gameList", response: [GameSocketResponse].self) { result in
            if let games = try? result.get() {
                completion(games.map { $0.toDomain() })
            }
        }
    }
    
    func onGameCreated(completion: @escaping (Game) -> Void) {
        socket.on("gameCreated", response: GameSocketResponse.self) { result in
            if let game = try? result.get() {
                completion(game.toDomain())
            }
        }
    }
    
    func onGameDeclined(completion: @escaping (String) -> Void) {
        socket.on("gameDeclined", response: String.self) { result in
            if let gameId = try? result.get() {
                completion(gameId)
            }
        }
    }
    
    func getGamesNext(userId: String, limit: Int, lastGameId: String, completion: @escaping ([Game]) -> Void) {
        struct Data: Codable {
            let userId: String
            let limit: Int
            let lastGameId: String
        }
        
        let request = Data(userId: userId, limit: limit, lastGameId: lastGameId)
        self.socket.emitWithAck("gameListNext", request: request, response: [GameSocketResponse].self) { result in
            if let games = try? result.get() {
                completion(games.map { $0.toDomain() })
            }
        }
    }
    
    // MARK: - Game update
    func onGameUnreadMsgUpdated(completion: @escaping (Game) -> Void) {
        socket.on("gameUnreadMessageUpdated", response: GameSocketResponse.self) { result in
            if let game = try? result.get() {
                completion(game.toDomain())
            }
        }
    }
    
    func onGameRoundPosted(completion: @escaping (Game) -> Void) {
        socket.on("roundPosted", response: GameSocketResponse.self) { result in
            if let game = try? result.get() {
                completion(game.toDomain())
            }
        }
    }
}
