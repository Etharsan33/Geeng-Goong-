//
//  EmptyView.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 01/10/2021.
//  Copyright © 2021 Geeng Goong. All rights reserved.
//

import UIKit
import Lottie
import MySwiftSpeedUpTools

class CustomEmptyView: BaseInstanceView {
    
    @IBOutlet weak var globalView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    var onCommitTryAgain: (() -> Void)?
    var onCommitCancel: (() -> Void)?
    
    var globalViewBackgroundColor: UIColor? {
        didSet {
            self.globalView?.backgroundColor = globalViewBackgroundColor
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        tryAgainButton?.setTitleColor(.black, for: .normal)
        tryAgainButton?.setCornerRadius(8)
        tryAgainButton?.setTitle("Veuillez réessayer", for: .normal)
        tryAgainButton?.titleLabel?.font = .gv_button()
        
        cancelButton?.backgroundColor = UIColor(hexa: "#cdcdcd")
        cancelButton?.setTitleColor(.white, for: .normal)
        cancelButton?.setCornerRadius(8)
        cancelButton?.setTitle("Annuler", for: .normal)
        cancelButton?.titleLabel?.font = .gv_button()
        
        animationView?.animation = Animation.named("loading")
        animationView?.backgroundBehavior = .pauseAndRestore
        animationView?.contentMode = .scaleAspectFit
    }
    
    @IBAction func tryAgainAction(_ sender: Any) {
        onCommitTryAgain?()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        onCommitCancel?()
    }
    
    func startAnimating() {
        animationView?.play(fromProgress: 0, toProgress: 1, loopMode: .loop)
    }
    
    func stopAnimating() {
        animationView.stop()
    }
}
