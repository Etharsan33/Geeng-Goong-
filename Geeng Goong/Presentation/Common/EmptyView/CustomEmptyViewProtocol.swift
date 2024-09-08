//
//  CustomEmptyViewProtocol.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 01/10/2021.
//  Copyright © 2021 Geeng Goong. All rights reserved.
//

import UIKit
import MySwiftSpeedUpTools

public protocol CustomEmptyViewProtocol : AnyObject {
    
    var emptyViewContainer: UIView? {get}
    var emptyViewBackgroundColor: UIColor? {get}
    var emptyViewImage: UIImage? {get}
    var emptyViewText: String? {get}
    var emptyViewTextColor: UIColor? {get}
    var emptyViewLoaderColor: UIColor? {get}
    var emptyViewTryAgainBackgroundColor: UIColor? {get}
    var emptyViewTryAgainTitle: String {get}
    var emptyViewFont: UIFont? {get}
    var emptyViewSpacingBetweenItem: CGFloat {get}
    var emptyViewTrailingLeadingConstant: CGFloat { get }
    
    func emptyViewTryAgainAction()
    func emptyViewCancelAction()
}

// MARK: - Enum Error
public enum CustomEmptyViewCustomError {
    case withMsg(String?)
    case withTitle(String?)
    case withTitleAndMsg(_ title: String?, _ msg: String?)
    
    fileprivate var displayTitle: String? {
        switch self {
        case .withTitle(let title):
            return title
        case .withTitleAndMsg(let title, _):
            return title
        default:
            return MyToolsLoc.Global.ALERT_ERROR_DEFAULT_TITLE.localized
        }
    }
    
    fileprivate var displayMessage: String? {
        switch self {
        case .withMsg(let msg):
            return msg
        case .withTitleAndMsg(_, let msg):
            return msg
        default:
            return MyToolsLoc.Global.ALERT_ERROR_DEFAULT_MESSAGE.localized
        }
    }
}

// MARK: - State
public enum CustomEmptyViewState {
    case loading
    case loadingWithCancelBtn
    case empty
    case emptyWithBtn(_ btnTitle: String)
    case none
    case error(_ error: CustomEmptyViewCustomError?)
    case errorWithReturnBtn(_ error: CustomEmptyViewCustomError?)
    case errorWithoutTryAgain(_ error: CustomEmptyViewCustomError?)
}

fileprivate struct AssociatedKeys {
    static var _emptyView: UInt8 = 0
    static var _emptyViewState: UInt8 = 0
    static var _emptyViewWithBackground: UInt8 = 0
}

extension CustomEmptyViewProtocol {
    
    public var emptyViewState: CustomEmptyViewState {
        get {
            return _emptyViewState
        }
        set {
            self.handleEmptyView(newValue)
            _emptyViewState = newValue
        }
    }
    
    private func handleEmptyView(_ state: CustomEmptyViewState) {
        guard let emptyView = getEmptyView() else { return }
        
        emptyView.globalViewBackgroundColor = self.emptyViewBackgroundColor
        
        emptyView.stackView?.spacing = emptyViewSpacingBetweenItem
        emptyView.indicatorView?.stopAnimating()
        emptyView.stopAnimating()
        
        emptyView.imageView?.image = emptyViewImage
        emptyView.imageView?.isHidden = (emptyViewImage == nil)
        
        emptyView.animationView?.isHidden = (emptyViewImage != nil)
        
        emptyView.messageLabel?.text = emptyViewText
        emptyView.messageLabel?.textColor = emptyViewTextColor
        emptyView.messageLabel?.font = emptyViewFont
        emptyView.indicatorView?.color = emptyViewLoaderColor
        emptyView.tryAgainButton?.backgroundColor = emptyViewTryAgainBackgroundColor
        emptyView.tryAgainButton?.setTitle(emptyViewTryAgainTitle, for: .normal)
        
        switch state {
        case .loading:
            emptyView.isHidden = false
            emptyView.messageLabel?.text = "Chargement"
            emptyView.messageLabel?.isHidden = false
            emptyView.tryAgainButton?.isHidden = true
            emptyView.cancelButton?.isHidden = true
            emptyView.indicatorView?.isHidden = (emptyViewImage == nil)
            (emptyViewImage == nil) ? emptyView.startAnimating() : emptyView.indicatorView?.startAnimating()
        case .loadingWithCancelBtn:
            emptyView.isHidden = false
            emptyView.messageLabel?.text = "Chargement"
            emptyView.messageLabel?.isHidden = false
            emptyView.tryAgainButton?.isHidden = true
            emptyView.cancelButton?.isHidden = false
            emptyView.indicatorView?.isHidden = (emptyViewImage == nil)
            (emptyViewImage == nil) ? emptyView.startAnimating() : emptyView.indicatorView?.startAnimating()
        case .empty:
            emptyView.isHidden = false
            emptyView.messageLabel?.isHidden = false
            emptyView.tryAgainButton?.isHidden = true
            emptyView.cancelButton?.isHidden = true
            emptyView.indicatorView?.isHidden = true
        case .emptyWithBtn(let btnTitle):
            emptyView.cancelButton?.setTitle(btnTitle, for: .normal)
            emptyView.cancelButton?.applyPrimaryBtnStyle()
            emptyView.cancelButton?.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            emptyView.isHidden = false
            emptyView.messageLabel?.isHidden = false
            emptyView.tryAgainButton?.isHidden = true
            emptyView.cancelButton?.isHidden = false
            emptyView.indicatorView?.isHidden = true
            if emptyViewImage == nil { emptyView.startAnimating() }
        case .none:
            emptyView.isHidden = true
        case .error(let error):
            if let error = error {
                emptyView.messageLabel?.text = error.displayMessage
            }
            emptyView.isHidden = false
            emptyView.messageLabel?.isHidden = false
            emptyView.tryAgainButton?.isHidden = false
            emptyView.cancelButton?.isHidden = true
            emptyView.indicatorView?.isHidden = true
        case .errorWithReturnBtn(let error):
            if let error = error {
                emptyView.messageLabel?.text = error.displayMessage
            }
            emptyView.isHidden = false
            emptyView.messageLabel?.isHidden = false
            emptyView.tryAgainButton?.isHidden = false
            emptyView.cancelButton?.isHidden = false
            emptyView.indicatorView?.isHidden = true
        case .errorWithoutTryAgain(let error):
            if let error = error {
                emptyView.messageLabel?.text = error.displayMessage
            }
            emptyView.isHidden = false
            emptyView.messageLabel?.isHidden = false
            emptyView.tryAgainButton?.isHidden = true
            emptyView.cancelButton?.isHidden = true
            emptyView.indicatorView?.isHidden = true
        }
    }
    
    private func getEmptyView() -> CustomEmptyView? {
        
        if _emptyView == nil, let container = emptyViewContainer {
            _emptyView = CustomEmptyView.instance
            _emptyView?.onCommitTryAgain = { [weak self] in
                self?.emptyViewTryAgainAction()
            }
            _emptyView?.onCommitCancel = { [weak self] in
                self?.emptyViewCancelAction()
            }
            _emptyView?.frame = container.frame
            _emptyView?.translatesAutoresizingMaskIntoConstraints = false
            container.insertSubview(_emptyView!, at: 0)
            
            // Always on top
            container.bringSubviewToFront(_emptyView!)
            _emptyView?.layer.zPosition = .greatestFiniteMagnitude
            
            _emptyView?.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            _emptyView?.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
            _emptyView?.heightAnchor.constraint(equalTo: container.heightAnchor).isActive = true
            _emptyView?.widthAnchor.constraint(equalTo: container.widthAnchor).isActive = true
            _emptyView?.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
            _emptyView?.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
            
            _emptyView?.trailingConstraint?.constant = self.emptyViewTrailingLeadingConstant
            _emptyView?.leadingConstraint?.constant = self.emptyViewTrailingLeadingConstant
        }
        
        return _emptyView
    }
    
    private(set) var _emptyView: CustomEmptyView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys._emptyView) as? CustomEmptyView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys._emptyView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private(set) var _emptyViewState: CustomEmptyViewState {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys._emptyViewState) as? CustomEmptyViewState) ?? CustomEmptyViewState.none
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys._emptyViewState, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var emptyViewContainer : UIView? {
        return nil
    }
    
    public var emptyViewBackgroundColor: UIColor? {
        return .white
    }
    
    public var emptyViewImage: UIImage? {
        return nil
    }
    
    public var emptyViewFont: UIFont? {
        return .gv_body1().semibolded
    }
    
    public var emptyViewTextColor : UIColor? {
        return .black
    }
    
    public var emptyViewLoaderColor : UIColor? {
        return .black
    }
    
    public var emptyViewTryAgainBackgroundColor : UIColor? {
        return .primaryColor
    }
    
    public var emptyViewTryAgainTitle: String {
        return "Veuillez réessayer"
    }
    
    public var emptyViewSpacingBetweenItem: CGFloat {
        return 20
    }
    
    public var emptyViewTrailingLeadingConstant: CGFloat {
        return 20
    }
}
