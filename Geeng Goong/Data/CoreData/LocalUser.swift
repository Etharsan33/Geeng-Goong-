//
//  LocalUser.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 20/12/2021.
//

import Foundation
import CoreData

class LocalUser: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, id: String, userName: String, avatarType: AvatarType) {
        
        self.init(context: context)
        
        self.id = id
        self.userName = userName
        self.avatarType = avatarType.rawValue
    }
}

extension LocalUser {
    
    func toDomain() -> User {
        func getAvatar() -> AvatarType {
            guard let type = self.avatarType,
                  let avatarType = AvatarType(rawValue: type) else {
                      return .blue
                  }
            return avatarType
        }
        
        return .init(id: self.id ?? UUID().uuidString,
                     userName: self.userName ?? "",
                     avatarType: getAvatar())
    }
}
