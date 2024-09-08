//
//  InfinityScrollCollectionView.swift
//  MySwiftBox
//
//  Created by ELANKUMARAN Tharsan on 06/04/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit

public protocol InfinityScrollProtocol {
    var total: Int? {get set}
    var startIndex: Int {get set}
    var endIndex: Int! {get set}
    var numberFetchItem: Int {get}
    
    var infiniteScrollTriggerOffset: CGFloat {get}
    var onCommitReachInfinityScroll: (()->())? {get set}
}

open class InfinityScrollViewController: UIViewController, InfinityScrollProtocol, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet open weak var collectionView: UICollectionView!
    
    // MARK: - InfinityScrollProtocol
    public var total: Int?
    public var startIndex: Int = 0
    public var endIndex: Int!
    
    open var numberFetchItem: Int {
        return 30
    }
    
    open var infiniteScrollTriggerOffset: CGFloat {
        return 500
    }
    
    open var onCommitReachInfinityScroll: (() -> ())?
    
    // MARK: - Private Variable
    private var currentScrollViewContentHeight: CGFloat = 0
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.endIndex = self.numberFetchItem
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        InfiniteScrollLoadingCollectionViewCell.registerNibFor(collectionView: collectionView)
    }
    
    // MARK: - Public function
    public func initialiseInfinityScroll() {
        self.total = nil
        self.startIndex = 0
        self.endIndex = self.numberFetchItem
        self.currentScrollViewContentHeight = 0
    }
}

// MARK: - UICollectionViewDataSource
extension InfinityScrollViewController {

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatalError("Subclasses must override")
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Subclasses must override")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension InfinityScrollViewController {
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let loadingCell = InfiniteScrollLoadingCollectionViewCell.reusableViewForCollection(collectionView: collectionView, indexPath: indexPath)
        return loadingCell
    }
    
    // Function could be override
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        // check (==) for add loading in last section
        if let total = self.total, endIndex < total && section == collectionView.numberOfSections - 1 {
            return CGSize(width: collectionView.bounds.width, height: InfiniteScrollLoadingCollectionViewCell.preferredHeight)
        }
        return .zero
    }
}

// MARK: - DidScroll
extension InfinityScrollViewController {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let bottom = abs(contentHeight - scrollView.frame.height)

        let bottomHeightPrefetch = abs(bottom - self.infiniteScrollTriggerOffset)

        // Check if reachBottom, contentHeight has changed and endIndex is less than total
        if offsetY >= bottomHeightPrefetch,
            contentHeight > self.currentScrollViewContentHeight,
            let total = self.total, (endIndex < total) {
            
            self.currentScrollViewContentHeight = contentHeight
            
            // Update with new values
            self.startIndex = self.endIndex + 1
            let _endIndex = self.startIndex + self.numberFetchItem
            self.endIndex = (_endIndex > total) ? total : _endIndex
            
            self.onCommitReachInfinityScroll?()
        }
    }
}
