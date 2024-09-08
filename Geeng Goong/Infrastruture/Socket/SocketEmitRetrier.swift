//
//  SocketEmitRetrier.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/02/2022.
//

import Foundation
import SocketIO

struct SocketEmitRetrier {
    let socket: SocketIOClient
    let interval: [Int]
    
    func emit<T>(event: String,
                 dataRequest: String,
                 dataResponse: @escaping ([Any]) -> Result<T, SocketError>,
                 result: @escaping (Result<T, SocketError>) -> Void) {
        
        let failureWrapper: (SocketError) -> Void = { error in
            guard let fireAtSecond = interval.first else {
                result(.failure(error))
                return
            }
            
            Self.launchTimer(fireAtSecond: fireAtSecond, fire: {
                var mutatingInterval = interval
                mutatingInterval.removeFirst()
                
                SocketEmitRetrier(socket: socket, interval: mutatingInterval)
                    .emit(event: event, dataRequest: dataRequest, dataResponse: dataResponse, result: result)
            })
        }
        
        socket.emitWithAck(event, dataRequest)
            .timingOut(after: 1) { data in
                let resultResponse = dataResponse(data)
                switch resultResponse {
                case .success(let response):
                    result(.success(response))
                case .failure(let error):
                    failureWrapper(error)
                }
        }
    }
    
    private static func launchTimer(fireAtSecond: Int, fire: @escaping () -> Void) {
        var seconds: Int = 0
        
        if fireAtSecond == 0 {
            fire()
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            seconds += 1
            if seconds == fireAtSecond {
                timer.invalidate()
                fire()
            }
        }
    }
}
