//
//  GameChatRepository.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 22/12/2021.
//

import Foundation

protocol GameChatRepository {
    func joinGame()
    func startGame(completion: @escaping (GameSocketResponse) -> Void)
    func declineGame(completion: @escaping (Bool) -> Void)
    func roundPost(roundType: RoundType)
    func sendNewMessage(msg: String, creationDateMs: Double,
                        completion: @escaping (Result<MessageSocketResponse, SocketError>) -> Void)
    func startTyping()
    func stopTyping()
    func getMoreMessages(limit: Int, lastMessageId: String, completion: @escaping ([MessageSocketResponse]) -> Void)
    
    func onGameStarted(completion: @escaping (GameSocketResponse) -> Void)
    func onGetGameDetail(completion: @escaping (GameSocketResponse) -> Void)
    func onGetMessages(completion: @escaping ([MessageSocketResponse]) -> Void)
    func onRoundPosted(completion: @escaping (GameSocketResponse) -> Void)
    func onMessagePosted(completion: @escaping (MessageSocketResponse) -> Void)
    func onUserIsTyping(completion: @escaping (Bool) -> Void)
}

