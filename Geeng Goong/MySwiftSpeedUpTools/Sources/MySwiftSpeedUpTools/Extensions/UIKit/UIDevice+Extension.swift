//
//  UIDevice+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 15/04/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

public extension UIDevice {
    
    // MARK: - Device Type
    static var isIpad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIphone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    // MARK: - Orientation
    static var isLandscape: Bool {
        return UIDevice.current.orientation.isValidInterfaceOrientation
            ? UIDevice.current.orientation.isLandscape
            : UIApplication.shared.statusBarOrientation.isLandscape
        
    }
    
    static var isPortrait: Bool {
        return UIDevice.current.orientation.isValidInterfaceOrientation
            ? UIDevice.current.orientation.isPortrait
            : UIApplication.shared.statusBarOrientation.isPortrait
    }
    
    // MARK: - Other
    @available(iOS 11.0, *)
    var hasNotch: Bool {
        // Case 1: Portrait && top safe area inset >= 44
        let case1 = !UIDevice.current.orientation.isLandscape && (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) >= 44
        // Case 2: Lanscape && left/right safe area inset > 0
        let case2 = UIDevice.current.orientation.isLandscape && ((UIApplication.shared.keyWindow?.safeAreaInsets.left ?? 0) > 0 || (UIApplication.shared.keyWindow?.safeAreaInsets.right ?? 0) > 0)
        
        return case1 || case2
    }
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
