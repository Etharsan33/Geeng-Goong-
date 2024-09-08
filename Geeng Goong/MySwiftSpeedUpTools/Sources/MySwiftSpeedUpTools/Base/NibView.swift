//
//  NibView.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 18/04/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

open class NibView: UIView {
    
    @IBOutlet public var contentView: UIView!
    
    // During initialization (Programmatic)
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = xibSetup()
    }
    
    // During initialization (IB Object)
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView = xibSetup()
    }
}
