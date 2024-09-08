//
//  SocketIOUsersOnline.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import Foundation
import SocketIO

protocol SocketIOUsersOnline {
    func onGetOnlineUsers(completion: @escaping ([User]) -> Void)
    func onUserJoined(completion: @escaping (User) -> Void)
    func onUserLeft(completion: @escaping (String) -> Void)
    
    func gameCreate(userID: String, completion: @escaping (String) -> Void)
}

class DefaultSocketIOUsersOnline: BaseSocketIO, SocketIOUsersOnline {
    
    override func socketConnected() {
        self.joinRoom()
    }
    
    private func joinRoom() {
        socket.emit("userJoin", "usersOnline")
    }
    
    deinit {
        self.leaveRoom()
    }
    
    private func leaveRoom() {
        socket.emit("userLeave", "usersOnline")
    }
    
    func onGetOnlineUsers(completion: @escaping ([User]) -> Void) {
        socket.on("userList", response: [UserSocketResponse].self) { result in
            if let users = try? result.get() {
                completion(users.map { $0.toDomain() })
            }
        }
    }
    
    func onUserJoined(completion: @escaping (User) -> Void) {
        socket.on("userJoined", response: UserSocketResponse.self) { result in
            if let user = try? result.get() {
                completion(user.toDomain())
            }
        }
    }
    
    func onUserLeft(completion: @escaping (String) -> Void) {
        socket.on("userLeaved") { data, _ in
            guard let userID = data.first as? String else {
                return
            }
            completion(userID)
        }
    }
    
    func gameCreate(userID: String, completion: @escaping (String) -> Void) {
        self.socket.emitWithAck("gameCreate", userID).timingOut(after: 1) { data in
            guard let gameID = data.first as? String else {
                return
            }
            completion(gameID)
        }
    }
}
