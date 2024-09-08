//
//  UITextField+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 15/04/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

public extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func setPlaceHolderTextColor(_ color: UIColor) {
        guard let holder = placeholder, !holder.isEmpty else { return }
        attributedPlaceholder = NSAttributedString(string: holder, attributes: [.foregroundColor: color])
    }
    
    func setLeftImage(image: UIImage?, width: CGFloat, height: CGFloat, spacing: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        let imageView = UIImageView(frame: .init(x: x, y: y, width: width, height: height))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        let view = UIView(frame: .init(x: 0, y: 0, width: width + spacing, height: height + spacing))
        view.addSubview(imageView)
        
        self.leftView = view
        self.leftViewMode = .always
    }
}
