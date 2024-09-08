//
//  Connectivity.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 05/03/2021.
//  Copyright © 2021 Geeng Goong. All rights reserved.
//

import UIKit
import Alamofire

class Connectivity {
    
    static let shared = Connectivity()
    private let networkReachability = NetworkReachabilityManager()
    private var isLoadFirstTime: Bool = true
    
    init() {
        networkReachability?.startListening(onUpdatePerforming: { [weak self] _ in
            // Not display if isFirstTime load with internet
            if self?.isLoadFirstTime == true && self?.hasNoNetwork == false {
                self?.isLoadFirstTime = false
                return
            }
            
            self?.isLoadFirstTime = false
        })
    }
    
    deinit {
        networkReachability?.stopListening()
    }
    
    var hasNoNetwork: Bool {
        return networkReachability?.isReachable == false
    }
}
