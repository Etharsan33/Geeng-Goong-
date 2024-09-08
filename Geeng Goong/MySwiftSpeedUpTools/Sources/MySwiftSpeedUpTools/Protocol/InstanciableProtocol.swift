//
//  InstanciableView.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 18/04/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

public protocol InstanciableViewProtocol : AnyObject { }

public extension InstanciableViewProtocol where Self : UIView {
    
    static var instance : Self {
        return instance(owner : self)
    }
    
    private static func instance(owner : Any?) -> Self {
        let fileName = String(describing: self)
        
        if Bundle.main.path(forResource: fileName, ofType: "nib") != nil {
            return Bundle.main.loadNibNamed(fileName, owner: owner, options: nil)!.first as! Self
        }
        
        // If nib is Not Found in main Bundle try in SPM modules
        return Bundle.module.loadNibNamed(fileName, owner: owner, options: nil)!.first as! Self
    }
}
