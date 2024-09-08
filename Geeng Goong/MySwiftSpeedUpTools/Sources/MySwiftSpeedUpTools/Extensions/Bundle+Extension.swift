//
//  Bundle+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 15/04/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import Foundation

public extension Bundle {
    
    var appDisplayName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    }
    
//    /// Returns the resource bundle associated with the current Swift module.
//    static var module: Bundle = {
//        let bundleName = "BioSwift_BioSwift"
//
//        let candidates = [
//            // Bundle should be present here when the package is linked into an App.
//            Bundle.main.resourceURL,
//
//            // Bundle should be present here when the package is linked into a framework.
////            Bundle(for: self).resourceURL,
//
//            // For command-line tools.
//            Bundle.main.bundleURL,
//        ]
//
//        for candidate in candidates {
//            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
//            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
//                return bundle
//            }
//        }
//        fatalError("unable to find bundle named BioSwift_BioSwift")
//    }()
}
