//
//  Helpers.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 15/04/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import Foundation
import UIKit

public class Helpers {
    
    @available(iOS 11.0, *)
    public enum SafeArea {
        case top
        case bottom
        case left
        case right
        
        public var value : CGFloat {
            switch self {
            case .top:
                return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
            case .bottom:
                return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            case .left:
                return UIApplication.shared.keyWindow?.safeAreaInsets.left ?? 0
            case .right:
                return UIApplication.shared.keyWindow?.safeAreaInsets.right ?? 0
            }
        }
    }
    
    public static func osVersionIs(maj : Int, minor : Int? = nil, patch : Int? = nil) -> Bool {
        
        let os = ProcessInfo().operatingSystemVersion
        
        if minor == nil && patch == nil {
            switch (os.majorVersion, os.minorVersion, os.patchVersion) {
            case (maj, _, _):
                return true
            default:
                return false
            }
        }
        else if minor != nil && patch == nil {
            switch (os.majorVersion, os.minorVersion, os.patchVersion) {
            case (maj, minor, _):
                return true
            default:
                return false
            }
        }
        else {
            switch (os.majorVersion, os.minorVersion, os.patchVersion) {
            case (maj, minor, patch):
                return true
            default:
                return false
            }
        }
        
        
    }
    
}
