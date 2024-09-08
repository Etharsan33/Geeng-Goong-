//
//  DefaultUserRepository.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 20/12/2021.
//

import Foundation
import RxSwift

class DefaultUserRepository: BaseRepository, UserRepository {
    
    func register(userName: String, avatarType: AvatarType) -> Observable<User> {
        return self.service
            .register(userName: userName, avatarColor: avatarType.rawValue)
            .map { $0.toDomain() }
    }
}
