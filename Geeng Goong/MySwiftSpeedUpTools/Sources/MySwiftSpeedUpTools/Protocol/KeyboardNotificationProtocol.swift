//
//  KeyboardNotificationProtocol.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 16/07/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

public protocol KeyboardNotificationProtocol : AnyObject {
    var containerKeyboardView: UIView? {get}
    func handleWillShowKeyboard(_ notification: Notification)
    func handleWillHideKeyboard(_ notification: Notification)
    func registerForKeyboardEvents()
    func unregisterForKeyboardEvents()
}

public extension KeyboardNotificationProtocol where Self: UIViewController {
    
    func registerForKeyboardEvents() {
        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            self.handleWillShowKeyboard(notification)
        }
        
        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            self.handleWillHideKeyboard(notification)
        }
    }
    
    func unregisterForKeyboardEvents() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func handleWillShowKeyboard(_ notification: Notification) {
        toggleKeyboard(isShow: true, notification)
    }
    
    func handleWillHideKeyboard(_ notification: Notification) {
        toggleKeyboard(isShow: false, notification)
    }
    
    private func toggleKeyboard(isShow: Bool, _ notification: Notification) {
        guard let scrollView = containerKeyboardView as? UIScrollView else { return }
        
        var keyboardHeight: CGFloat = 0
        var velocityKeyboard: Double = 0.1
        
        var bottomPadding: CGFloat = 0
        let customOffset: CGFloat = 10
        
        // get bottom safe area
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            bottomPadding = window?.safeAreaInsets.bottom ?? 0
        }
        
        if let keyboardVelocity = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
            velocityKeyboard = keyboardVelocity.doubleValue
        }
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
        
        UIView.animate(withDuration: velocityKeyboard, animations: {
            scrollView.contentInset.bottom = (isShow) ? (keyboardHeight + bottomPadding + customOffset) : 0
        })
    }
}
