//
//  GameListViewCell.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 29/11/2021.
//

import UIKit

class GameListViewCell: UICollectionViewCell {
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var messageContainerView: UIStackView!
    @IBOutlet private weak var messageImageView: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var badgeContainerView: UIStackView!
    @IBOutlet private weak var badgeView: UIView!
    @IBOutlet private weak var badgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.usernameLabel.font = .gv_body1().semibolded
        self.badgeView.backgroundColor = .gg_yellow
        self.badgeLabel.font = .gv_body2().semibolded
        self.messageLabel.font = .gv_body1()
        self.messageLabel.textColor = .gg_blue
        self.messageImageView.image = UIImage(named: "racket_icon")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.badgeContainerView.isHidden = false
        self.messageContainerView.isHidden = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.userImageView.setCornerRadius(self.userImageView.frame.height / 2)
        self.badgeView.setCornerRadius(self.badgeView.frame.height / 2)
    }
    
    func configure(game: Game) {
        self.userImageView.image = game.opponent.avatarType.image
        self.usernameLabel.text = game.opponent.userName
        
        let badge = game.unreadMessageCount
        self.badgeContainerView.isHidden = (badge == 0)
        self.badgeLabel.text = "\(badge)"
        
        let message: String? = game.action?.gameListMessage
        self.messageContainerView.isHidden = (message == nil)
        self.messageLabel.text = message
        
        self.layoutIfNeeded()
    }
}
