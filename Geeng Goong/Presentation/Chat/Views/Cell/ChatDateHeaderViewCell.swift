//
//  ChatDateHeaderViewCell.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 31/01/2022.
//

import UIKit

final class ChatDateHeaderViewCell: MessageReusableView {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.backgroundColor = .gv_lightGrey
        containerView.setCornerRadius(4)
        
        label.font = .gv_smallBody().bolded
    }
    
    func configure(text: String) {
        label.text = text
    }
    
    //MARK: - Instance
    public class func registerNibFor(collectionView: UICollectionView) {
        let bundle = Bundle.main
        let nib = UINib(nibName: String(describing: self), bundle: bundle)
        collectionView.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: self))
    }
    
    public class func reusableViewForCollection(collectionView: UICollectionView, indexPath : IndexPath) -> Self {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: self), for: indexPath as IndexPath) as! Self
    }
}
