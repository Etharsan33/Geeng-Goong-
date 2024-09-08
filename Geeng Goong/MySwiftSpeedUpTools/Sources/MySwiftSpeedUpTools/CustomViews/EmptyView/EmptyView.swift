//
//  EmptyView.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 15/07/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

open class EmptyView: BaseInstanceView {
    
    @IBOutlet weak var globalView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    var onCommitTryAgain: (() -> Void)?
    
    var globalViewBackgroundColor: UIColor? {
        didSet {
            self.globalView?.backgroundColor = globalViewBackgroundColor
        }
    }
    
    var retryTitle: String? {
        didSet {
            UIView.performWithoutAnimation {
                self.tryAgainButton?.setTitle(retryTitle, for: .normal)
            }
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        tryAgainButton?.setTitleColor(.white, for: .normal)
        tryAgainButton?.setCornerRadius(23)
    }
    
    @IBAction func tryAgainAction(_ sender: Any) {
        onCommitTryAgain?()
    }
}
