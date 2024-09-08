//
//  UserListOnlineViewCell.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import UIKit

class UserListOnlineViewCell: UITableViewCell {
    
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        contentView.backgroundColor = selected ? .gg_lightBlue : .white
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.usernameLabel.font = .gv_body1().semibolded
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setCornerRadius(40)
        self.userImageView.setCornerRadius(self.userImageView.frame.height / 2)
    }
    
    func configure(user: User) {
        self.userImageView.image = user.avatarType.image
        self.usernameLabel.text = user.userName
    }
}
