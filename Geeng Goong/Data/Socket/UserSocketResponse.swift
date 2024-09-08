//
//  UserSocketResponse.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 26/11/2021.
//

import Foundation

struct UserSocketResponse: Decodable {
    let id: String
    let userName: String
    let avatarColor: AvatarType
}

// MARK: - To Domain
extension UserSocketResponse {
    
    func toDomain() -> User {
        return .init(id: self.id,
                     userName: self.userName,
                     avatarType: self.avatarColor)
    }
}
