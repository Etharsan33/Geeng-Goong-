//
//  BaseCollectionHeaderView.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 17/04/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

open class BaseCollectionHeaderView: BaseCollectionReusableView {
    
    //MARK: Life Cycle
    override open func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
    }
    
    //MARK: Instance
    open override class func registerNibFor(collectionView: UICollectionView) {
        let bundle = isNibIsInModule() ? Bundle.module : Bundle(for: self)
        let nib = UINib(nibName: String(describing: self), bundle: bundle)
        collectionView.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: self))
    }
    
    open override class func reusableViewForCollection(collectionView: UICollectionView, indexPath : IndexPath) -> Self {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: self), for: indexPath as IndexPath) as! Self
    }
    
}
