//
//  CustomInfinityScrollViewController.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 06/12/2021.
//

import UIKit
import MySwiftSpeedUpTools

class CustomInfinityScrollViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet open weak var collectionView: UICollectionView!
    
    public var pageAfter: String?
    
    open var numberFetchItem: Int {
        return 30
    }
    
    open var infiniteScrollTriggerOffset: CGFloat {
        return 100
    }
    
    open var onCommitReachInfinityScroll: (() -> ())?
    
    // MARK: - Private Variable
    private var currentScrollViewContentHeight: CGFloat = 0
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        InfiniteScrollLoadingCollectionViewCell.registerNibFor(collectionView: collectionView)
    }
    
    // MARK: - Public function
    public func initialiseInfinityScroll() {
        self.pageAfter = nil
        self.currentScrollViewContentHeight = 0
    }
}

// MARK: - UICollectionViewDataSource
extension CustomInfinityScrollViewController {

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatalError("Subclasses must override")
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Subclasses must override")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CustomInfinityScrollViewController {
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let loadingCell = InfiniteScrollLoadingCollectionViewCell.reusableViewForCollection(collectionView: collectionView, indexPath: indexPath)
        return loadingCell
    }
    
    // Function could be override
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        // check (==) for add loading in last section
        if self.pageAfter != nil && section == collectionView.numberOfSections - 1 {
            return CGSize(width: collectionView.bounds.width, height: 44)
        }
        return .zero
    }
}

// MARK: - DidScroll
extension CustomInfinityScrollViewController {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let bottom = abs(contentHeight - scrollView.frame.height)

        let bottomHeightPrefetch = abs(bottom - self.infiniteScrollTriggerOffset)

        // Check if reachBottom, contentHeight has changed and endIndex is less than total
        if offsetY >= bottomHeightPrefetch,
           contentHeight > self.currentScrollViewContentHeight,
           self.pageAfter != nil {
            
            self.currentScrollViewContentHeight = contentHeight
            self.onCommitReachInfinityScroll?()
        }
    }
}
