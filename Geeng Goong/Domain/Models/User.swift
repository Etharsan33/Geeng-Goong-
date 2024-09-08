//
//  User.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import Foundation

struct User: Codable, Equatable {
    let id: String
    let userName: String
    let avatarType: AvatarType
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
        lhs.userName == rhs.userName &&
        lhs.avatarType == rhs.avatarType
    }
}

extension User {
    
    func saveInUserDefaults() {
        let userData = try? JSONEncoder().encode(self)
        UserDefaults.standard.set(userData, forKey: "localUser")
    }
    
    static func getFromUserDefaults() -> User? {
        let data = UserDefaults.standard.object(forKey: "localUser") as? Data
        
        guard let userData = data,
            let cachedUser = try? JSONDecoder().decode(User.self, from: userData) else {
                return nil
        }
        
        return cachedUser
    }
}
