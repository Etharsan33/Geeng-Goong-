//
//  Localizable.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 18/04/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import Foundation

public protocol LocalizableProtocol {
    var rawValue: String { get }
}

extension LocalizableProtocol {
    
    /// Localized string from the main Bundle or if not found, from Bundle called
    public var localized : String {
        
        let string = rawValue
        let frameworkName = String(reflecting: self).components(separatedBy: ".").first
        
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let localizableFile = "Localizable"
        let undefinedValue = appName + localizableFile + ":[Undefined String : " + string + "]"
        var val = Bundle.main.localizedString(forKey: string, value: undefinedValue, table: localizableFile)
        if val == undefinedValue {
            val = Bundle.main.localizedString(forKey: string, value: undefinedValue, table: "LocalizablePending")
        }
        
        // Try to get Localizable in SPM modules
        if val == undefinedValue {
            val = Bundle.module.localizedString(forKey: string, value: undefinedValue, table: localizableFile)
        }
        
        if val == undefinedValue, let frameworkName = frameworkName, let frameworkUrl = Bundle.main.privateFrameworksURL {
            // Bundle.allFrameworks use that if not work Bundle main
            let getFramework = frameworkUrl.appendingPathComponent("\(frameworkName).framework")
            if let pathToFramework = Bundle(url: getFramework) {
                val = pathToFramework.localizedString(forKey: string, value: undefinedValue, table: localizableFile)
            }
            
            // Get localizable + framework Name in Framework
            if val == undefinedValue {
                let getFramework = frameworkUrl.appendingPathComponent("\(frameworkName).framework")
                if let pathToFramework = Bundle(url: getFramework) {
                    val = pathToFramework.localizedString(forKey: string, value: undefinedValue, table: localizableFile + "+" + frameworkName)
                }
            }
            
            // Get localizable + framework Name in Main Bundle
            if val == undefinedValue {
                val = Bundle.main.localizedString(forKey: string, value: undefinedValue, table: localizableFile + "+" + frameworkName)
            }
        }
        
        if val == undefinedValue, let frameworkName = frameworkName, let frameworkUrl = Bundle.main.privateFrameworksURL {
            let locPendingFile = "LocalizablePending"
            let getFramework = frameworkUrl.appendingPathComponent("\(frameworkName).framework")
            if let pathToFramework = Bundle(url: getFramework) {
                val = pathToFramework.localizedString(forKey: string, value: undefinedValue, table: locPendingFile)
            }
            
            // Get localizable + framework Name in Framework
            if val == undefinedValue {
                let getFramework = frameworkUrl.appendingPathComponent("\(frameworkName).framework")
                if let pathToFramework = Bundle(url: getFramework) {
                    val = pathToFramework.localizedString(forKey: string, value: undefinedValue, table: locPendingFile + "+" + frameworkName)
                }
            }
            
            // Get localizable + framework Name in Main Bundle
            if val == undefinedValue {
                val = Bundle.main.localizedString(forKey: string, value: undefinedValue, table: locPendingFile + "+" + frameworkName)
            }
        }
        
        if val == undefinedValue {
            
            #if DEBUG
            assertionFailure("Missing Localizable : \(string)")
            #endif
            
            val = string.lowercased()
        }
        
        return val
    }
}
