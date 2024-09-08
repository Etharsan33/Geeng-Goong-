//
//  UIButton+Extension.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 23/11/2021.
//

import Foundation
import UIKit

extension UIButton {
    
    func applyPrimaryBtnStyle() {
        self.backgroundColor = .gg_lightBlue
        self.tintColor = .gg_blue
        self.setCornerRadius(22)
        self.titleLabel?.font = .gv_subTitle().bolded
    }
}
