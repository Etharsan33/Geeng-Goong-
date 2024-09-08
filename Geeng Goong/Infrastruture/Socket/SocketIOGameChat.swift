//
//  SocketIOGameChat.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 27/11/2021.
//

import Foundation
import SocketIO

protocol SocketIOGameChat {
    func joinGameRoom()
    
    func onGetMessages(completion: @escaping ([MessageSocketResponse]) -> Void)
    func onMessagePosted(completion: @escaping (MessageSocketResponse) -> Void)
    func onGetGameDetail(completion: @escaping (GameSocketResponse) -> Void)
    func onRoundPosted(completion: @escaping (GameSocketResponse) -> Void)
    func onGameStarted(completion: @escaping (GameSocketResponse) -> Void)
    func onUserIsTyping(completion: @escaping (Bool) -> Void)
    
    func sendNewMessage(msg: String, creationDateMs: Double,
                        completion: @escaping (Result<MessageSocketResponse, SocketError>) -> Void)
    func messageListBefore(limit: Int, lastMessageId: String, completion: @escaping ([MessageSocketResponse]) -> Void)
    func gameStart(completion: @escaping (GameSocketResponse) -> Void)
    func gameDecline(completion: @escaping (Bool) -> Void)
    func roundPost(roundType: RoundType)
    func startTyping()
    func stopTyping()
}

class DefaultSocketIOGameChat: BaseSocketIO, SocketIOGameChat {
    
    private let gameID: String
    
    private var socketIsConnected: Bool {
        return self.socket.status == .connected
    }
    
    required init(socket: SocketIOClient, gameID: String) {
        self.gameID = gameID
        super.init(socket: socket)
    }
    
    required init(socket: SocketIOClient) {
        fatalError("init(socket:) has not been implemented")
    }
    
    func joinGameRoom() {
        socket.emit("userJoin", "game-\(self.gameID)")
    }
    
    deinit {
        self.leaveRoom()
    }
    
    private func leaveRoom() {
        socket.emit("userLeave", "game-\(self.gameID)")
    }
    
    func onGetMessages(completion: @escaping ([MessageSocketResponse]) -> Void) {
        socket.on("messageList", response: [MessageSocketResponse].self) { result in
            if let messages = try? result.get() {
                completion(messages)
            }
        }
    }
    
    func sendNewMessage(msg: String, creationDateMs: Double,
                        completion: @escaping (Result<MessageSocketResponse, SocketError>) -> Void) {
        
        if !self.socketIsConnected {
            completion(.failure(.socketNotConnected))
            return
        }
        
        struct Data: Encodable {
            let text: String
            let gameId: String
            let creationDateMs: Double
        }
        let request = Data(text: msg, gameId: self.gameID, creationDateMs: creationDateMs)
        
        self.socket.emitWithAck("messagePost", request: request, response: MessageSocketResponse.self) { result in
            completion(result)
        }
    }
    
    func onMessagePosted(completion: @escaping (MessageSocketResponse) -> Void) {
        socket.on("messagePosted", response: MessageSocketResponse.self) { result in
            if let message = try? result.get() {
                completion(message)
            }
        }
    }
    
    func onGetGameDetail(completion: @escaping (GameSocketResponse) -> Void) {
        socket.on("gameDetail", response: GameSocketResponse.self) { result in
            if let game = try? result.get() {
                completion(game)
            }
        }
    }
    
    func messageListBefore(limit: Int, lastMessageId: String, completion: @escaping ([MessageSocketResponse]) -> Void) {
        
        struct Data: Encodable {
            let gameId: String
            let limit: Int
            let lastMessageId: String
        }
        
        let request = Data(gameId: self.gameID, limit: limit, lastMessageId: lastMessageId)
        self.socket.emitWithAck("messageListBefore", request: request, response: [MessageSocketResponse].self) { result in
            if let messages = try? result.get() {
                completion(messages)
            }
        }
    }
    
    func gameStart(completion: @escaping (GameSocketResponse) -> Void) {
        self.socket.emitWithAck("gameStart", dataRequest: self.gameID, response: GameSocketResponse.self) { result in
            if let game = try? result.get() {
                completion(game)
            }
        }
    }
    
    func gameDecline(completion: @escaping (Bool) -> Void) {
        self.socket.emitWithAck("gameDecline", dataRequest: self.gameID, response: Bool?.self) { result in
            
            let isPassed: Bool? = try? result.get()
            completion(isPassed ?? false)
        }
    }
    
    func roundPost(roundType: RoundType) {
        struct Data: Codable {
            let gameId: String
            let roundType: String
        }
        
        guard let data = try? JSONEncoder().encode(Data(gameId: self.gameID, roundType: roundType.rawValue)),
              let stringData = String(data: data, encoding: .utf8) else {
                  return
              }
        
        self.socket.emitWithAck("roundPost", stringData).timingOut(after: 1) { _ in }
    }
    
    func onRoundPosted(completion: @escaping (GameSocketResponse) -> Void) {
        socket.on("roundPosted", response: GameSocketResponse.self) { result in
            if let game = try? result.get() {
                completion(game)
            }
        }
    }
    
    func onGameStarted(completion: @escaping (GameSocketResponse) -> Void) {
        socket.on("gameStarted", response: GameSocketResponse.self) { result in
            if let game = try? result.get() {
                completion(game)
            }
        }
    }
    
    func startTyping() {
        socket.emit("userStartTyping", self.gameID)
    }
    
    func stopTyping() {
        socket.emit("userStopTyping", self.gameID)
    }
    
    func onUserIsTyping(completion: @escaping (Bool) -> Void) {
        self.socket.on("userIsTyping") { data, _ in
            let isTyping = (data.first as? Bool) ?? false
            completion(isTyping)
        }
    }
}

