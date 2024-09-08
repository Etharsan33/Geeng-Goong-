//
//  UIView+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 15/04/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

public extension UIView {
    
    // MARK: - Xib
    func xibSetup() -> UIView? {
        guard let view = loadViewFromNib(String(describing: type(of: self))) else { return nil }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        return view
    }
    
    private func loadViewFromNib(_ nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(
            withOwner: self,
            options: nil).first as? UIView
    }
    
    // MARK: - Layer
    func addShadowWithCornerRadius(shadowColor: UIColor = .black, offSet: CGSize = CGSize(width: 0, height: 2), opacity: Float = 0.2, shadowRadius: CGFloat = 2.0, cornerRadius: CGFloat, corners: UIRectCorner = .allCorners, border: (CGFloat, UIColor)? = nil, fillColor: UIColor = .white) {
        
        let shadowLayerName = "shadow_radius_layer"
        if let shadowLayer = self.layer.sublayers?.first(where: {$0.name == shadowLayerName}) {
            shadowLayer.removeFromSuperlayer()
        }
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.name = shadowLayerName
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let cgPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size).cgPath
        shadowLayer.path = cgPath
        shadowLayer.fillColor = fillColor.cgColor
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.shadowPath = cgPath
        shadowLayer.shadowOffset = offSet
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowRadius = shadowRadius
        
        if let border = border {
            shadowLayer.strokeColor = border.1.cgColor
            shadowLayer.lineWidth = border.0
        }
        
        self.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    func setBorder(borderWidth: CGFloat = 1, color: UIColor = .black) {
        self.layer.masksToBounds = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    @available(iOS 11.0, *)
    func setCornerRadius(corners: CACornerMask, radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
    }
    
    func setShadowLayer(opacity: Float = 0.2, offset : CGSize = CGSize(width: 0, height: 2), radius : CGFloat = 2.0, color : UIColor = .black) {
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.shadowColor = color.cgColor
        self.layer.masksToBounds = false
    }
    
    func addGradiantLayer(frame: CGRect, colors: [CGColor], opacity: Float) {
        let layer = CAGradientLayer()
        layer.frame = frame
        layer.colors = colors
        layer.opacity = opacity
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(layer, at: 0)
    }
    
    // MARK: - Animation
    func growShrinkAnimation(isGrow: Bool) {
        self.isHidden = false
        let initialScale: CGFloat = isGrow ? 0 : 1
        self.transform = CGAffineTransform(scaleX: initialScale, y: initialScale)
        
        UIView.animate(withDuration: 0.25, animations: {
            let scale: CGFloat = isGrow ? 1 : 0.001
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: { _ in
            self.isHidden = !isGrow
        })
    }
    
    func fadeInOutAnimation(isFadeIn: Bool) {
        self.isHidden = false
        let initialAlpha: CGFloat = isFadeIn ? 0 : 1
        self.alpha = initialAlpha
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            let alpha: CGFloat = isFadeIn ? 1 : 0
            self.alpha = alpha
        }, completion: { _ in
            self.isHidden = !isFadeIn
        })
    }
    
    func shake(count: Float = 2, for duration: TimeInterval = 0.25, withTranslation translation: Float = 5) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
    
    // MARK: - Other
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func firstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        
        for (_, view) in self.subviews.enumerated() {
            
            if let v = view.firstResponder() {
                return v
            }
            
            if view.isFirstResponder {
                return view
            }
        }
        
        return nil
    }
}

