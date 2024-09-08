//
//  AvatarType.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 23/11/2021.
//

import Foundation
import UIKit

enum AvatarType: String, CaseIterable, Codable {
    case blue, pink, yellow, green
    
    var image: UIImage? {
        switch self {
        case .blue:
            return UIImage(named: "blue_user")
        case .pink:
            return UIImage(named: "pink_user")
        case .yellow:
            return UIImage(named: "yellow_user")
        case .green:
            return UIImage(named: "green_user")
        }
    }
}
