//
//  ViewModelsAssembly.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import Swinject
import SwinjectAutoregistration

class ViewModelsAssembly: Assembly {
    
    func assemble(container: Container) {
        container.autoregister(LoginViewModel.self, initializer: DefaultLoginViewModel.init(userRepository: socketIOConnectivity:))
        
        container.autoregister(UserListOnlineViewModel.self, arguments: User.self, UserListOnlineViewModelActions.self, initializer: DefaultUserListOnlineViewModel.init(socket: currentUser: actions:))
        
        container.autoregister(GameListViewModel.self, argument: User.self, initializer: DefaultGameListViewModel.init(socket: currentUser:))
        
        container.register(GameChatViewModel.self) { (r: Resolver, gameID: String, currentUser: User) in
            
            let socket = r.resolve(SocketIOGameChat.self, argument: gameID)!
            let repo = r.resolve(GameChatRepository.self, argument: socket)!
            
            return DefaultGameChatViewModel(
                gameID: gameID,
                gameStatusUseCase: r.resolve(GameStatusUseCase.self, argument: repo)!,
                fetchGameDetailUseCase: r.resolve(FetchGameDetailUseCase.self, argument: repo)!,
                fetchMessagesUseCase: r.resolve(FetchMessagesUseCase.self, argument: repo)!,
                gameRoundPostUseCase: r.resolve(GameRoundPostUseCase.self, argument: repo)!,
                postMessageUseCase: r.resolve(PostMessageUseCase.self, argument: repo)!,
                userTypingMsgUseCase: r.resolve(UserTypingMessageUseCase.self, argument: repo)!,
                fetchMoreMsgsUseCase: r.resolve(FetchMoreMessagesUseCase.self, argument: repo)!,
                currentUser: currentUser)
        }
    }
}
