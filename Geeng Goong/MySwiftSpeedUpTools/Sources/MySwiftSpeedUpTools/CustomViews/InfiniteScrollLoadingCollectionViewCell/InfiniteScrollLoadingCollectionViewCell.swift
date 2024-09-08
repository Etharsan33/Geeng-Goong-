//
//  InfiniteScrollLoadingCollectionViewCell.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 19/03/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

open class InfiniteScrollLoadingCollectionViewCell: BaseCollectionFooterView {
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    static let preferredHeight: CGFloat = 44
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        indicatorView.color = .black
        indicatorView.startAnimating()
    }
}
