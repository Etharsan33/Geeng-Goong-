//
//  UIColor+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 15/04/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

public extension UIColor {
    
    /// Init a UIColor from an hexa String and an alpha
    ///
    /// - Parameters:
    ///   - hexa: ex: #DEDEDE
    ///   - alpha: from 0 to 1
    convenience init(hexa: String, alpha: Double) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        
        var index = hexa.index(hexa.startIndex, offsetBy: 0)
        if hexa.hasPrefix("#") {
            index = hexa.index(hexa.startIndex, offsetBy: 1)
        }
        
        let hex = String(hexa[index...])
        let scanner = Scanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        
        if scanner.scanHexInt64(&hexValue) {
            if hex.count == 6 {
                red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
                blue = CGFloat(hexValue & 0x0000FF) / 255.0
                
                self.init(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
            }else{
                self.init(red:0, green:0, blue:0, alpha:0)
            }
        }else{
            self.init(red:0, green:0, blue:0, alpha:0)
        }
        
    }
    
    /// Init a UIColor from an hexa String
    ///
    /// - Parameter hexa: ex: #DEDEDE
    convenience init(hexa: String) {
        self.init(hexa: hexa, alpha: 1)
    }
    
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let multiplier = CGFloat(255.999999)
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        }
        else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
    
    static var random: UIColor {
        let r:CGFloat  = .random(in: 0 ... 1)
        let g:CGFloat  = .random(in: 0 ... 1)
        let b:CGFloat  = .random(in: 0 ... 1)
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
