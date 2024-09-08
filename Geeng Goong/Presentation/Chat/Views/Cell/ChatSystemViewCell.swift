//
//  ChatSystemViewCell.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 07/12/2021.
//

import UIKit

final class ChatSystemViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    
    var didTapLeftButton: (() -> Void)?
    var didTapRightButton: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setCornerRadius(8)
        self.backgroundColor = .gg_lightOrange
        
        titleLabel.font = .gv_body1().bolded
        [leftButton, rightButton].forEach { button in
            button?.titleLabel?.font = .gv_body2().bolded
        }
    }
    
    // MARK: - Actions
    @IBAction func leftButtonTapAction() {
        self.didTapLeftButton?()
    }
    
    @IBAction func rightButtonTapAction() {
        self.didTapRightButton?()
    }
    
    func configure(dataView: ChatBotDataView) {
        titleLabel.text = dataView.title
        leftButton.setTitle(dataView.leftButtonType.title, for: .normal)
        rightButton.setTitle(dataView.rightButtonType.title, for: .normal)
        
        configureStyleButton(button: leftButton, type: dataView.leftButtonType.type)
        configureStyleButton(button: rightButton, type: dataView.rightButtonType.type)
    }
    
    private func configureStyleButton(button: UIButton, type: ChatBotDataView.ButtonType.`Type`) {
        switch type {
        case .simple:
            button.tintColor = .gg_orange
            button.backgroundColor = .clear
        case .`default`:
            button.setCornerRadius(8)
            button.tintColor = .black
            button.backgroundColor = .gg_orange
        }
    }
}
