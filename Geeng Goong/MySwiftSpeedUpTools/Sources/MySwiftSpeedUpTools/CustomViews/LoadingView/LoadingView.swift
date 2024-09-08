//
//  LoadingView.swift
//  Gestteam
//
//  Created by ELANKUMARAN Tharsan on 06/12/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import Foundation
import UIKit

open class LoadingView: BaseInstanceView {
    
    public enum LoadingViewState {
        case loading
        case retry
        case cancel
        case cancelAndRetry
        case none
        case titleOnly
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var actionStackView: UIStackView!
    @IBOutlet public weak var cancelButton: UIButton!
    @IBOutlet public weak var retryButton: UIButton!
    
    var retryButtonAction : (()->())?
    var cancelButtonAction : (()->())?
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.state = .none
    }
    
    public var state : LoadingViewState = .none {
        didSet {
            DispatchQueue.main.async {
                self.isHidden = false
                
                switch self.state {
                case .loading:
                    self.actionStackView?.isHidden = true
                    self.titleLabel?.isHidden = true
                    self.cancelButton?.isHidden = true
                    self.retryButton?.isHidden = true
                    self.activityIndicator?.startAnimating()
                case .retry:
                    self.titleLabel?.isHidden = false
                    self.actionStackView?.isHidden = false
                    self.cancelButton?.isHidden = true
                    self.retryButton?.isHidden = false
                    self.activityIndicator?.stopAnimating()
                case .cancel:
                    self.titleLabel?.isHidden = false
                    self.actionStackView?.isHidden = false
                    self.cancelButton?.isHidden = false
                    self.retryButton?.isHidden = true
                    self.activityIndicator?.stopAnimating()
                    
                case .cancelAndRetry:
                    self.titleLabel?.isHidden = false
                    self.actionStackView?.isHidden = false
                    self.cancelButton?.isHidden = false
                    self.retryButton?.isHidden = false
                    self.activityIndicator?.stopAnimating()
                    
                case .none:
                    self.isHidden = true
                    
                case .titleOnly:
                    self.titleLabel?.isHidden = false
                    self.actionStackView?.isHidden = true
                    self.cancelButton?.isHidden = true
                    self.retryButton?.isHidden = true
                    self.activityIndicator?.stopAnimating()
                }
            }
        }
    }
    
    //MARK: Action
    @IBAction func leftButtonAction(_ sender: Any) {
        cancelButtonAction?()
    }
    
    @IBAction func rightButtonAction(_ sender: Any) {
        retryButtonAction?()
    }
    
}
