//
//  AppMainAssembly.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import UIKit
import Swinject
import SwinjectAutoregistration
import SocketIO

class AppMainAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(ServerConfigType.self) { resolver -> ServerConfigType in
            return ServerConfig.default
        }
        
        container.register(AppEnvironment.self) { resolver -> AppEnvironment in
            let config = resolver.resolve(ServerConfigType.self)!
            
            let currentUser = User.getFromUserDefaults()
            let oauthToken = (currentUser != nil) ? OauthToken(token: currentUser!.id) : nil
            let apiService = Service(serverConfig: config, token: oauthToken)
            
            let socketIOConnectivity = DefaultSocketIOConnectivity(serviceConfig: config)
            let persistenceService = DefaultPersistenceCoreDataService()

            let env = DefaultEnvironment(apiService: apiService,
                                         socketIOConnectivity: socketIOConnectivity,
                                         persistenceCoreDataService: persistenceService)
            return AppEnvironment(environment: env, currentUser: currentUser)
        }.inObjectScope(.container)
        
        container.register(ServiceType.self) { resolver -> ServiceType in
            return resolver.resolve(AppEnvironment.self)!.environment.apiService
        }
        
        container.register(SocketIOConnectivity.self) { resolver -> SocketIOConnectivity in
            return resolver.resolve(AppEnvironment.self)!.environment.socketIOConnectivity
        }
        
        container.register(SocketIOClient.self) { resolver -> SocketIOClient in
            return resolver.resolve(AppEnvironment.self)!.environment.socketIOConnectivity.socket
        }
        
        container.register(PersistenceCoreDataService.self) { resolver -> PersistenceCoreDataService in
            return resolver.resolve(AppEnvironment.self)!.environment.persistenceCoreDataService
        }
    }
}

