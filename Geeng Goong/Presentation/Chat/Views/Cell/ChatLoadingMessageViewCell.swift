//
//  ChatLoadingMessageViewCell.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 21/02/2022.
//

import UIKit

final class ChatLoadingMessageViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var messageView: UIView!
    @IBOutlet private weak var leftSpacingMessageView: UIView!
    @IBOutlet private weak var rightSpacingMessageView: UIView!
    @IBOutlet private weak var messageWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var leftSpacingBottomView: UIView!
    @IBOutlet private weak var rightSpacingBottomView: UIView!
    
    static let preferredHeight: CGFloat = 140
    
    public func configure(messageWidth: CGFloat, isStackLeft: Bool) {
        self.messageWidthConstraint.constant = messageWidth
        self.leftSpacingMessageView.isHidden = isStackLeft
        self.rightSpacingMessageView.isHidden = !isStackLeft
        self.leftSpacingBottomView.isHidden = isStackLeft
        self.rightSpacingBottomView.isHidden = !isStackLeft
    }
    
    public func showSkeleton() {
        UIView.showSkeletonAnimation(for: [messageView, bottomView])
    }
}
