//
//  Environment.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import Foundation

protocol Environment {
    var apiService: ServiceType { get set }
    var socketIOConnectivity: SocketIOConnectivity { get set }
    var persistenceCoreDataService: PersistenceCoreDataService { get set }
}

struct DefaultEnvironment: Environment {
    
    /// A type that exposes endpoints for fetching data.
    var apiService: ServiceType
    
    /// Main Socket
    var socketIOConnectivity: SocketIOConnectivity
    
    /// Core Data Service
    var persistenceCoreDataService: PersistenceCoreDataService
}
