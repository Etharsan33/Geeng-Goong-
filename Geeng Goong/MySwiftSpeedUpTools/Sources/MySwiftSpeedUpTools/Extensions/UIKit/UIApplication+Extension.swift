//
//  UIApplication+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 15/04/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

public extension UIApplication {
    
    /// Set color to the status bar
    ///
    /// - Parameter color
    static func setStatusBarBackgroundColor(_ color: UIColor) {
        
        if #available(iOS 13.0, *) {
            guard let view = UIApplication.shared.keyWindow else { return }
            
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.statusBarFrame.size.height
            
            if let _view = view.viewWithTag(895632) {
                _view.backgroundColor = color
                return
            }
            
            let statusbarView = UIView()
            statusbarView.tag = 895632 // STATUS BAR ID
            statusbarView.backgroundColor = color
            view.addSubview(statusbarView)
            UIApplication.shared.keyWindow?.bringSubviewToFront(statusbarView)
          
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor
                .constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor
                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor
                .constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor).isActive = true
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = color
        }
    }
    
    static func getStatusBarBackgroundColor() -> UIColor? {
        if #available(iOS 13, *) {
            // STATUS BAR ID
            return (UIApplication.shared.keyWindow?.viewWithTag(895632))?.backgroundColor
        } else {
            return (UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView)?.backgroundColor
        }
    }
    
    // MARK: - TopViewController
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    // MARK: - Share Action
    private class func _share(_ data: [Any],
                              applicationActivities: [UIActivity]?,
                              setupViewControllerCompletion: ((UIActivityViewController) -> Void)?) {
        let activityViewController = UIActivityViewController(activityItems: data, applicationActivities: nil)
        setupViewControllerCompletion?(activityViewController)

        UIApplication.topViewController()?.present(activityViewController, animated: true, completion: nil)
    }

    class func share(_ data: Any...,
                     applicationActivities: [UIActivity]? = nil,
                     setupViewControllerCompletion: ((UIActivityViewController) -> Void)? = nil) {
        _share(data, applicationActivities: applicationActivities, setupViewControllerCompletion: setupViewControllerCompletion)
    }
    class func share(_ data: [Any],
                     applicationActivities: [UIActivity]? = nil,
                     setupViewControllerCompletion: ((UIActivityViewController) -> Void)? = nil) {
        _share(data, applicationActivities: applicationActivities, setupViewControllerCompletion: setupViewControllerCompletion)
    }
}
