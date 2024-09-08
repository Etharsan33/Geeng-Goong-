//
//  UICollectionViewCell+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 08/05/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

public extension UICollectionViewCell {
    
    // MARK: - Instance
    class func registerNibFor(collectionView: UICollectionView) {
        let nib = UINib(nibName: String(describing: self), bundle: Bundle(for: self))
        collectionView.register(nib, forCellWithReuseIdentifier: String(describing: self))
    }
    
    class func cellForCollection(collectionView: UICollectionView, indexPath : IndexPath) -> Self {
        return collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: self), for: indexPath) as! Self
    }
}
