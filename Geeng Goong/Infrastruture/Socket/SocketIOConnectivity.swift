//
//  SocketIOConnectivity.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 26/11/2021.
//

import Foundation
import SocketIO

protocol SocketIOConnectivity {
    var socket: SocketIOClient { get }
    
    init(serviceConfig: ServerConfigType)
    func connect(with userID: String)
    func closeConnection()
    func isConnected() -> Bool
}

class DefaultSocketIOConnectivity: SocketIOConnectivity {
    
    private var manager: SocketManager
    
    var socket: SocketIOClient {
        return self.manager.defaultSocket
    }
    
    required init(serviceConfig: ServerConfigType) {
        self.manager = SocketManager(socketURL: serviceConfig.apiBaseUrl,
                                     config: [])
    }
    
    func connect(with userID: String) {
        print("USER ID : ", userID)
        
        self.manager.setConfigs([.connectParams(["token": userID])])
        self.socket.connect(withPayload: nil)
        
        self.socket.on(clientEvent: .connect) { data, ack in
            print("SOCKET CONNECT !!!")
        }
        
        self.socket.on(clientEvent: .error) { data, ack in
            print("\nSocket error\n")
        }
    }
    
    func closeConnection() {
        self.socket.removeAllHandlers()
        self.socket.disconnect()
    }
    
    func isConnected() -> Bool {
        return self.socket.status == .connected
    }
}
