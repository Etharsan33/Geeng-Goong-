//
//  BaseInstanceView.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 13/04/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

open class BaseInstanceView: UIView, InstanciableViewProtocol {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if self.subviews.count == 0{
            self.commonInit()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if self.subviews.count == 0{
            self.commonInit()
        }
    }
    
    open func commonInit() {
        _ = self.xibSetup()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
}
