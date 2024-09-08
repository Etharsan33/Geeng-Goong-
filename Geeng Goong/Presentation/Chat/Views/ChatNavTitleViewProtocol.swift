//
//  ChatNavTitleViewProtocol.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 27/01/2022.
//

import UIKit

class ChatNavTitleView {
    
    private var imageView: UIImageView?
    private var titleLabel: UILabel?
    private var stackViewBottom: UIStackView?
    private var subTitleLabel: UILabel?
    private var onlineIndicatorView: UIView?
    
    var didTapAction: (() -> Void)?
    
    func createView(navBarWidth: CGFloat?) -> UIView {
        let size: CGFloat = 36
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        let imageView = UIImageView(frame: .init(x: 0, y: 0, width: size, height: size))
        imageView.contentMode = .scaleAspectFit
        imageView.setCornerRadius(8)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: size).isActive = true
        imageView.makeSkeletonable(8)
        
        let stackViewContainer = UIStackView()
        stackViewContainer.axis = .vertical
        
        let titleLabel = UILabel()
        titleLabel.text = " "
        titleLabel.font = .gv_body1().semibolded
        titleLabel.textColor = .black
        titleLabel.isSkeletonable = true
        titleLabel.skeletonCornerRadius = 8
        
        let stackViewBottom = UIStackView()
        stackViewBottom.axis = .horizontal
        stackViewBottom.spacing = 4
        stackViewBottom.alignment = .center
        stackViewBottom.makeSkeletonable()
        
        let subTitleLabel = UILabel()
        subTitleLabel.makeSkeletonable()
        subTitleLabel.text = " "
        subTitleLabel.font = .gv_smallBody()
        subTitleLabel.textColor = .lightGray
        
        let onlineIndicatorView = UIView()
        onlineIndicatorView.makeSkeletonable()
        onlineIndicatorView.backgroundColor = .lightGray
        onlineIndicatorView.setCornerRadius(4)
        onlineIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        onlineIndicatorView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        onlineIndicatorView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        stackViewBottom.addArrangedSubview(onlineIndicatorView)
        stackViewBottom.addArrangedSubview(subTitleLabel)
        
        stackViewContainer.addArrangedSubview(titleLabel)
        stackViewContainer.addArrangedSubview(stackViewBottom)
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(stackViewContainer)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.heightAnchor.constraint(equalToConstant: size).isActive = true
        
        if let width = navBarWidth {
            stackView.widthAnchor.constraint(equalToConstant: width * 0.7).isActive = true
        }
        
        stackView.addTapGestureRecognizer { [weak self] in
            self?.didTapAction?()
        }
        
        self.imageView = imageView
        self.titleLabel = titleLabel
        self.stackViewBottom = stackViewBottom
        self.subTitleLabel = subTitleLabel
        self.onlineIndicatorView = onlineIndicatorView
        
        return stackView
    }
    
    func showSkeleton() {
        UIView.showSkeletonAnimation(for: [imageView, titleLabel, stackViewBottom])
    }
    
    func configure(image: UIImage?, title: String?) {
        self.imageView?.image = image
        self.titleLabel?.text = title
        
        UIView.hideSkeletonAnimation(for: [imageView, titleLabel])
    }
    
    func configure(isOnline: Bool) {
        subTitleLabel?.text = isOnline ? "En ligne" : "Hors-ligne"
        onlineIndicatorView?.backgroundColor = isOnline ? .systemGreen : UIColor(hexa: "#8b8989")
        
        UIView.hideSkeletonAnimation(for: [stackViewBottom])
    }
}
