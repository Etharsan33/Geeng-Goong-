//
//  BaseSocketIO.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 25/11/2021.
//

import Foundation
import SocketIO

protocol SocketIOProtocol {
    var socket: SocketIOClient { get set }
    
    init(socket: SocketIOClient)
    func socketConnected()
}

class BaseSocketIO: SocketIOProtocol {
    
    var socket: SocketIOClient
    
    required init(socket: SocketIOClient) {
        self.socket = socket
        
        if socket.status == .connected {
            self.socketConnected()
        }
        
        self.socket.on(clientEvent: .connect) { [weak self] data, ack in
            self?.socketConnected()
        }
    }
    
    @objc func socketConnected() {}
}

// MARK: - Extension SocketIOClient
extension SocketIOClient {
    
    func emitWithAck<R: Encodable, T: Decodable>(_ event: String,
                                                 request: R,
                                                 response: T.Type,
                                                 completion: @escaping (Result<T, SocketError>) -> Void) {
        
        guard let dataRequest = self.encodeDataRequest(request) else {
            completion(.failure(.mappingError))
            return
        }
        
        let retrier = SocketEmitRetrier(socket: self, interval: [1, 3, 10])
        
        retrier.emit(event: event,
                     dataRequest: dataRequest,
                     dataResponse: self.convertDataToResponse,
                     result: completion)
    }
    
    func emitWithAck<T: Decodable>(_ event: String,
                                   dataRequest: String,
                                   response: T.Type,
                                   completion: @escaping (Result<T, SocketError>) -> Void) {
        
        self.emitWithAck(event, dataRequest)
            .timingOut(after: 1) { [weak self] data in
                guard let self = self else {
                    completion(.failure(.unknown))
                    return
                }
                completion(self.convertDataToResponse(data))
        }
    }
    
    func on<T: Decodable>(_ event: String,
                          response: T.Type,
                          completion: @escaping (Result<T, SocketError>) -> Void) {
        
        self.on(event) { [weak self] data, _ in
            guard let self = self else {
                completion(.failure(.unknown))
                return
            }
            completion(self.convertDataToResponse(data))
        }
    }
    
    // MARK: - Private
    private func convertDataToResponse<T: Decodable>(_ array: [Any]) -> Result<T, SocketError> {
        guard let any = array.first else {
            return .failure(.unknown)
        }
        
        guard JSONSerialization.isValidJSONObject(any),
              let data = try? JSONSerialization.data(withJSONObject: any, options: []) else {
            return .failure(.jsonNotValid)
        }
        
        guard let decodable = try? JSONDecoder().decode(T.self, from: data) else {
            return .failure(.mappingError)
        }
        return .success(decodable)
    }
    
    private func encodeDataRequest<T: Encodable>(_ data: T) -> String? {
        guard let data = try? JSONEncoder().encode(data),
              let stringData = String(data: data, encoding: .utf8) else {
                  return nil
              }
        return stringData
    }
}
