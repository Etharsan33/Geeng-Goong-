//
//  UITextView+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 12/08/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

extension UITextView {
    
    func setTextWithLineSpace(_ spacing: CGFloat, text: String, font: UIFont) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = spacing
        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: style, .font: font]
        self.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
