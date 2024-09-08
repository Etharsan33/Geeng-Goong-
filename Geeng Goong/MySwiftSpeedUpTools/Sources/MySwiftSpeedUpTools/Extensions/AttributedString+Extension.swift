//
//  AttributedString+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 15/04/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import Foundation
import UIKit

// MARK: - NSAttributedString extension
public extension NSAttributedString {
    
    /// Height of a AttributedString constrained with a given width for a given Font
    ///
    /// - Parameters:
    ///   - width:
    ///   - font:
    /// - Returns: Height of width constrained AttributedString
    func heightWithConstrainedWidth(width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        
        return boundingBox.height
    }
    
    /// Width of a AttributedString constrained with a given width for a given Font
    ///
    /// - Parameters:
    ///   - height:
    ///   - font:
    /// - Returns: Width of height constrained AttributedString
    func widthWithConstrainedHeight(height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        
        return boundingBox.width
    }
}
