//
//  RepositoriesAssembly.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import Swinject
import SwinjectAutoregistration

class RepositoriesAssembly: Assembly {
    
    func assemble(container: Container) {
        container.autoregister(UserRepository.self, initializer: DefaultUserRepository.init(service:))
        container.autoregister(GameChatRepository.self, argument: SocketIOGameChat.self, initializer: DefaultGameChatRepository.init(socket:))
    }
}
