//
//  RegisterResponse.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import Foundation

struct RegisterResponse: Decodable {
    
    struct RegisterUser: Decodable {
        let id: String
        let userName: String
        let avatarColor: AvatarType
    }
    let user: RegisterUser
}

// MARK: - To Domain
extension RegisterResponse {
    
    func toDomain() -> User {
        return .init(id: self.user.id,
                     userName: self.user.userName,
                     avatarType: self.user.avatarColor)
    }
}

