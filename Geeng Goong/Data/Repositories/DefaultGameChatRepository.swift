//
//  DefaultGameChatRepository.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 22/12/2021.
//

import Foundation

class DefaultGameChatRepository: GameChatRepository {
    
    private let socket: SocketIOGameChat
    
    init(socket: SocketIOGameChat) {
        self.socket = socket
    }
    
    // Emit
    func joinGame() {
        self.socket.joinGameRoom()
    }
    
    func startGame(completion: @escaping (GameSocketResponse) -> Void) {
        self.socket.gameStart { game in
            completion(game)
        }
    }
    
    func declineGame(completion: @escaping (Bool) -> Void) {
        self.socket.gameDecline { isDeclined in
            completion(isDeclined)
        }
    }
    
    func roundPost(roundType: RoundType) {
        self.socket.roundPost(roundType: roundType)
    }
    
    func sendNewMessage(msg: String, creationDateMs: Double, completion: @escaping (Result<MessageSocketResponse, SocketError>) -> Void) {
        self.socket.sendNewMessage(msg: msg, creationDateMs: creationDateMs) { message in
            completion(message)
        }
    }
    
    func startTyping() {
        self.socket.startTyping()
    }
    
    func stopTyping() {
        self.socket.stopTyping()
    }
    
    func getMoreMessages(limit: Int, lastMessageId: String, completion: @escaping ([MessageSocketResponse]) -> Void) {
        self.socket.messageListBefore(limit: limit, lastMessageId: lastMessageId) { messages in
            completion(messages)
        }
    }
    
    // Listener
    func onGameStarted(completion: @escaping (GameSocketResponse) -> Void) {
        self.socket.onGameStarted { game in
            completion(game)
        }
    }
    
    func onGetGameDetail(completion: @escaping (GameSocketResponse) -> Void) {
        self.socket.onGetGameDetail { game in
            completion(game)
        }
    }
    
    func onGetMessages(completion: @escaping ([MessageSocketResponse]) -> Void) {
        self.socket.onGetMessages { messages in
            completion(messages)
        }
    }
    
    func onRoundPosted(completion: @escaping (GameSocketResponse) -> Void) {
        self.socket.onRoundPosted { game in
            completion(game)
        }
    }
    
    func onMessagePosted(completion: @escaping (MessageSocketResponse) -> Void) {
        self.socket.onMessagePosted { message in
            completion(message)
        }
    }
    
    func onUserIsTyping(completion: @escaping (Bool) -> Void) {
        self.socket.onUserIsTyping { isTyping in
            completion(isTyping)
        }
    }
}
