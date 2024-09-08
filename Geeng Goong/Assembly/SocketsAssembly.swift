//
//  SocketsAssembly.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 25/11/2021.
//

import Swinject
import SwinjectAutoregistration

class SocketsAssembly: Assembly {
    
    func assemble(container: Container) {
        container.autoregister(SocketIOUsersOnline.self, initializer: DefaultSocketIOUsersOnline.init(socket:))
        
        container.autoregister(SocketIOGameList.self, initializer: DefaultSocketIOGameList.init(socket:))
        
        container.autoregister(SocketIOGameChat.self, argument: String.self, initializer: DefaultSocketIOGameChat.init(socket: gameID:))
    }
}
