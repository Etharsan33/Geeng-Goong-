//
//  BaseRepository.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import Foundation

class BaseRepository {
    
    internal let service: ServiceType
    
    init(service: ServiceType) {
        self.service = service
    }
}
