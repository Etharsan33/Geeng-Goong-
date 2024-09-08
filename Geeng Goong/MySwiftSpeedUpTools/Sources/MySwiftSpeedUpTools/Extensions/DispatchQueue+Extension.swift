//
//  DispatchQueue+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 16/07/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import Dispatch

public extension DispatchQueue {
    
    /// dispatch queue is the main queue
    static var isMainQueue: Bool {
        enum Static {
            static var key: DispatchSpecificKey<Void> = {
                let key = DispatchSpecificKey<Void>()
                DispatchQueue.main.setSpecific(key: key, value: ())
                return key
            }()
        }
        return DispatchQueue.getSpecific(key: Static.key) != nil
    }
    
    /// dispatch queue is the specified queue
    static func isCurrent(_ queue: DispatchQueue) -> Bool {
        let key = DispatchSpecificKey<Void>()
        
        queue.setSpecific(key: key, value: ())
        defer {
            queue.setSpecific(key: key, value: nil)
        }
        return DispatchQueue.getSpecific(key: key) != nil
    }
}
