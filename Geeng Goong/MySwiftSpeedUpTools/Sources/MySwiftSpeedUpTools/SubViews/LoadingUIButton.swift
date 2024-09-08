//
//  LoadingUIButton.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 14/08/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import UIKit

public class LoadingUIButton: UIButton {

    @IBInspectable var indicatorColor : UIColor = .white

    private var originalButtonText: String?
    private var activityIndicator: UIActivityIndicatorView!

    public enum State {
        case loading, none
    }
    public var loadingState: State = .none {
        didSet {
            switch loadingState {
            case .loading:
                self.showLoading()
                self.isUserInteractionEnabled = false
            case .none:
                self.hideLoading()
                self.isUserInteractionEnabled = true
            }
        }
    }
    
    private func showLoading() {
        originalButtonText = self.titleLabel?.text
        self.setTitle("", for: .normal)

        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }

        showSpinning()
    }

    private func hideLoading() {
        guard let activityIndicator = activityIndicator else {
            return
        }
        
        DispatchQueue.main.async(execute: {
            self.setTitle(self.originalButtonText, for: .normal)
            activityIndicator.stopAnimating()
        })
    }

    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = indicatorColor
        return activityIndicator
    }

    private func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }

    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)

        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }

}
