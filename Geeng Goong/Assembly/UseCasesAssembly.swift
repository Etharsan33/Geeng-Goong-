//
//  UseCasesAssembly.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 23/12/2021.
//

import Swinject
import SwinjectAutoregistration

class UseCasesAssembly: Assembly {
    
    func assemble(container: Container) {
        container.autoregister(GameStatusUseCase.self, argument: GameChatRepository.self, initializer: DefaultGameStatusUseCase.init(gameChatRepository:))
        
        container.autoregister(FetchGameDetailUseCase.self, argument: GameChatRepository.self, initializer: DefaultFetchGameDetailUseCase.init(gameChatRepository:))
        
        container.autoregister(FetchMessagesUseCase.self, argument: GameChatRepository.self, initializer: DefaultFetchMessagesUseCase.init(repository: persistenceService:))
        
        container.autoregister(GameRoundPostUseCase.self, argument: GameChatRepository.self, initializer: DefaultGameRoundPostUseCase.init(gameChatRepository:))
        
        container.autoregister(PostMessageUseCase.self, argument: GameChatRepository.self, initializer: DefaultPostMessageUseCase.init(gameChatRepository: persistenceService:))
        
        container.autoregister(UserTypingMessageUseCase.self, argument: GameChatRepository.self, initializer: DefaultUserTypingMessageUseCase.init(gameChatRepository:))
        
        container.autoregister(FetchMoreMessagesUseCase.self, argument: GameChatRepository.self, initializer: DefaultFetchMoreMessagesUseCase.init(gameChatRepository: persistenceService:))
    }
}
