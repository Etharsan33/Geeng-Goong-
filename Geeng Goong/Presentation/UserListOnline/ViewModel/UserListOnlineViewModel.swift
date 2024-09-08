//
//  UserListOnlineViewModel.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import UIKit
import RxSwift
import RxRelay

struct UserListOnlineViewModelActions {
    var showGameChat: (String) -> Void
}

protocol UserListOnlineViewModelInput {
    func viewDidLoad()
    func tapStartBtn(userSelected: User)
}

protocol UserListOnlineViewModelOutput {
    var usersLoaded: BehaviorRelay<[User]> { get }
}

protocol UserListOnlineViewModel: UserListOnlineViewModelInput, UserListOnlineViewModelOutput {}

class DefaultUserListOnlineViewModel: UserListOnlineViewModel {
    
    private let socket: SocketIOUsersOnline
    private let currentUser: User
    private let actions: UserListOnlineViewModelActions
    
    // MARK: - Output
    let usersLoaded = BehaviorRelay<[User]>(value: [])
    let showGameList = PublishSubject<String>()
    
    init(socket: SocketIOUsersOnline, currentUser: User, actions: UserListOnlineViewModelActions) {
        self.socket = socket
        self.currentUser = currentUser
        self.actions = actions
    }
    
    // MARK: - Input
    func viewDidLoad() {
        self.listenSocketRooms()
    }
    
    func tapStartBtn(userSelected: User) {
        socket.gameCreate(userID: userSelected.id) { [weak self] gameID in
            self?.actions.showGameChat(gameID)
        }
    }
    
    // MARK: - Private
    private func listenSocketRooms() {
        socket.onGetOnlineUsers { [weak self] users in
            self?.usersLoaded.accept(users)
        }
        
        socket.onUserJoined { [weak self] user in
            guard var users = self?.usersLoaded.value,
                  !users.contains(where: { $0.id == user.id }) else { return }
            users.insert(user, at: 0)
            self?.usersLoaded.accept(users)
        }
        
        socket.onUserLeft { [weak self] userID in
            guard var users = self?.usersLoaded.value,
            let index = users.firstIndex(where: { $0.id == userID }) else {
                return
            }
            users.remove(at: index)
            self?.usersLoaded.accept(users)
        }
    }
}
