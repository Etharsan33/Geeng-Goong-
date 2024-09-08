//
//  EmptyViewProtocol.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 15/07/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

public protocol EmptyViewProtocol : AnyObject {
    
    var emptyViewContainer: UIView? {get}
    var emptyViewBackgroundColor: UIColor? {get}
    var emptyViewImage: UIImage? {get}
    var emptyViewText: String? {get}
    var emptyViewTextColor: UIColor? {get}
    var emptyViewLoaderColor: UIColor? {get}
    var emptyViewTryAgainBackgroundColor: UIColor? {get}
    var emptyViewFont: UIFont? {get}
    var emptyViewSpacingBetweenItem: CGFloat {get}
    var emptyViewTrailingLeadingConstant: CGFloat { get }
    
    func emptyViewTryAgainAction()
}

// MARK: - Enum Error
public enum EmptyViewCustomError {
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
public enum EmptyViewState {
    case loading
    case empty
    case none
    case error(_ error: EmptyViewCustomError?)
    case errorWithoutTryAgain(_ error: EmptyViewCustomError?)
}

fileprivate struct AssociatedKeys {
    static var _emptyView: UInt8 = 0
    static var _emptyViewState: UInt8 = 0
    static var _emptyViewWithBackground: UInt8 = 0
}

extension EmptyViewProtocol {
    
    public var emptyViewState: EmptyViewState {
        get {
            return _emptyViewState
        }
        set {
            self.handleEmptyView(newValue)
            _emptyViewState = newValue
        }
    }
    
    private func handleEmptyView(_ state: EmptyViewState) {
        guard let emptyView = getEmptyView() else { return }
        
        emptyView.globalViewBackgroundColor = self.emptyViewBackgroundColor
        
        emptyView.stackView.spacing = emptyViewSpacingBetweenItem
        emptyView.indicatorView.stopAnimating()
        
        emptyView.imageView?.image = emptyViewImage
        emptyView.imageView.isHidden = (emptyViewImage == nil)
        
        emptyView.messageLabel?.text = emptyViewText
        emptyView.messageLabel?.textColor = emptyViewTextColor
        emptyView.messageLabel?.font = emptyViewFont
        emptyView.indicatorView?.color = emptyViewLoaderColor
        emptyView.retryTitle = MyToolsLoc.Global.TRY_AGAIN.localized
        emptyView.tryAgainButton?.backgroundColor = emptyViewTryAgainBackgroundColor
        emptyView.tryAgainButton?.setTitleColor((emptyViewTryAgainBackgroundColor == .white) ? .black : .white, for: .normal)
        
        switch state {
        case .loading:
            emptyView.isHidden = false
            emptyView.messageLabel?.isHidden = true
            emptyView.tryAgainButton?.isHidden = true
            emptyView.indicatorView?.isHidden = false
            emptyView.indicatorView.startAnimating()
            break
        case .empty:
            emptyView.isHidden = false
            emptyView.messageLabel?.isHidden = false
            emptyView.tryAgainButton?.isHidden = true
            emptyView.indicatorView?.isHidden = true
            break
        case .none:
            emptyView.isHidden = true
            break
        case .error(let error):
            if let error = error {
                emptyView.messageLabel?.text = error.displayMessage
            }
            emptyView.isHidden = false
            emptyView.messageLabel?.isHidden = false
            emptyView.tryAgainButton?.isHidden = false
            emptyView.indicatorView?.isHidden = true
            break
        case .errorWithoutTryAgain(let error):
            if let error = error {
                emptyView.messageLabel?.text = error.displayMessage
            }
            emptyView.isHidden = false
            emptyView.messageLabel?.isHidden = false
            emptyView.tryAgainButton?.isHidden = true
            emptyView.indicatorView?.isHidden = true
            break
        }
        
    }
    
    private func getEmptyView() -> EmptyView? {
        
        if _emptyView == nil, let container = emptyViewContainer {
            _emptyView = EmptyView.instance
            _emptyView?.onCommitTryAgain = { [weak self] in
                self?.emptyViewTryAgainAction()
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
    
    private(set) var _emptyView: EmptyView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys._emptyView) as? EmptyView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys._emptyView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private(set) var _emptyViewState: EmptyViewState {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys._emptyViewState) as? EmptyViewState) ?? EmptyViewState.none
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys._emptyViewState, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var emptyViewContainer : UIView? {
        return nil
    }
    
    public var emptyViewImage: UIImage? {
        return nil
    }
    
    public var emptyViewBackgroundColor: UIColor? {
        return .clear
    }
    
    public var emptyViewTryAgainBackgroundColor: UIColor? {
        return .systemRed
    }
    
    public var emptyViewTextColor : UIColor? {
        return .black
    }
    
    public var emptyViewLoaderColor : UIColor? {
        return .black
    }
    
    public var emptyViewFont: UIFont? {
        return .systemFont(ofSize: 14)
    }
    
    public var emptyViewSpacingBetweenItem: CGFloat {
        return 20
    }
    
    public var emptyViewTrailingLeadingConstant: CGFloat {
        return 20
    }
}
