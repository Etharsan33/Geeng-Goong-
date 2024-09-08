//
//  LoginConfigurationProtocol.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 17/07/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import Foundation
import UIKit

public protocol LoginConfigurationProtocol: AnyObject {
    var LCPidentifiantTextField: UITextField? {get}
    var identifiantType: LoginConfigurationIdentifiantType {get}
    var LCPpasswordTextField: UITextField? {get}
}

public enum LoginConfigurationIdentifiantType {
    case email
    case text
    case none
    
    var textContentType: UITextContentType? {
        switch self {
        case .email:
            return .emailAddress
        case .text:
            if #available(iOS 11.0, *) {
                return .username
            } else {
                return .name
            }
        case .none:
            return .none
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .email:
            return .emailAddress
        case .text, .none:
            return .default
        }
    }
}

fileprivate struct LoginConfigAssociatedKeys {
    static var _identifiantTextField: UInt8 = 0
    static var _identifiantType: UInt8 = 0
    static var _passwordTextField: UInt8 = 0
}

public extension LoginConfigurationProtocol {
    
    var identifiantType: LoginConfigurationIdentifiantType {
        get {
            return self._identifiantType
        }
        set {
            self._identifiantType = newValue
        }
    }
    
    var LCPidentifiantTextField: UITextField? {
        get {
            return self._identifiantTextField
        }
        set {
            self._identifiantTextField = newValue
        }
    }
    
    func configureTextFields(textColor: UIColor, font: UIFont, identifiantPlaceholder: String?, passwordPlaceholder: String?) {
        self.LCPidentifiantTextField?.textContentType = self.identifiantType.textContentType
        self.LCPidentifiantTextField?.keyboardType = self.identifiantType.keyboardType
        
        if #available(iOS 11.0, *) {
            self.LCPpasswordTextField?.textContentType = .password
        }
        self.LCPpasswordTextField?.isSecureTextEntry = true
        
        self.LCPidentifiantTextField?.textColor = textColor
        self.LCPpasswordTextField?.textColor = textColor
        
        self.LCPidentifiantTextField?.placeholder = identifiantPlaceholder
        self.LCPpasswordTextField?.placeholder = passwordPlaceholder
        self.LCPidentifiantTextField?.font = font
        self.LCPpasswordTextField?.font = font
    }
    
    var LCPpasswordTextField: UITextField? {
        get {
            return self._passwordTextField
        }
        set {
            self._passwordTextField = newValue
        }
    }
    
    // MARK: - AssociatedKeys
    private(set) var _identifiantType: LoginConfigurationIdentifiantType {
        get {
            return (objc_getAssociatedObject(self, &LoginConfigAssociatedKeys._identifiantType) as? LoginConfigurationIdentifiantType) ?? .none
        }
        set(newValue) {
            objc_setAssociatedObject(self, &LoginConfigAssociatedKeys._identifiantType, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private(set) var _identifiantTextField: UITextField? {
        get {
            return objc_getAssociatedObject(self, &LoginConfigAssociatedKeys._identifiantTextField) as? UITextField
        }
        set(newValue) {
            objc_setAssociatedObject(self, &LoginConfigAssociatedKeys._identifiantTextField, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private(set) var _passwordTextField: UITextField? {
        get {
            return objc_getAssociatedObject(self, &LoginConfigAssociatedKeys._passwordTextField) as? UITextField
        }
        set(newValue) {
            objc_setAssociatedObject(self, &LoginConfigAssociatedKeys._passwordTextField, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
