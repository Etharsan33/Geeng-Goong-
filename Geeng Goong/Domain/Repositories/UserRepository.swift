//
//  UserRepository.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import Foundation
import RxSwift

protocol UserRepository {
    func register(userName: String, avatarType: AvatarType) -> Observable<User>
}
