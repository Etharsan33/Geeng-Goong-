//
//  UIView+Skeleton.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 22/02/2022.
//

import UIKit
import SkeletonView

extension UIView {
    
    func makeSkeletonable(_ cornerRadius: Float? = nil) {
        self.isSkeletonable = true
        if let cornerRadius = cornerRadius {
            self.skeletonCornerRadius = cornerRadius
        }
    }
    
    static func makeSketonable(for views: [UIView?], cornerRadius: Float? = nil) {
        views.forEach {
            $0?.makeSkeletonable(cornerRadius)
        }
    }
    
    static func showSkeletonAnimation(for views: [UIView?]) {
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 1)
        
        views.forEach {
            $0?.showAnimatedGradientSkeleton(usingGradient: SkeletonAppearance.default.gradient, animation: animation, transition: .none)
        }
    }
    
    static func hideSkeletonAnimation(for views: [UIView?]) {
        views.forEach {
            $0?.hideSkeleton(reloadDataAfter: true, transition: .none)
        }
    }
}
