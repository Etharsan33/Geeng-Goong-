//
//  UIView+Extension.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 23/11/2021.
//

import UIKit

extension UIView {

    func aspectRation(_ ratio: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: ratio, constant: 0)
    }
}
