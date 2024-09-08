//
//  UIStackView+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 15/04/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

public extension UIStackView {
    
    func removeAllArrangedSubviews(excludeView: [UIView?] = []) {
        
        let removedSubviews = arrangedSubviews.filter({!excludeView.contains($0)}).reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    func removeElementProperly(_ view: UIView?) {
        guard let view = view else {return}
        
        if arrangedSubviews.contains(where: { $0 == view }) {
            removeArrangedSubview(view)
            NSLayoutConstraint.deactivate(view.constraints)
            view.removeFromSuperview()
        }
    }
}
