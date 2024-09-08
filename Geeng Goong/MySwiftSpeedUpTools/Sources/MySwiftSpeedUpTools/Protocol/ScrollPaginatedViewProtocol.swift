//
//  ScrollPaginatedViewProtocol.swift
//  MySwiftSpeedUpTools
//
//  Created by Elankumaran Tharsan on 07/02/2021.
//

import UIKit

fileprivate struct AssociatedKeys {
    static var _currentPage: UInt8 = 0
}

public protocol ScrollPaginatedViewProtocol: AnyObject {
    var paginatedCurrentPage: Int { get set }
    func scrollPaginatedViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>, oneByOne: Bool, pageOffsets: [CGFloat])
    func scrollPaginatedProgress(_ scrollView: UIScrollView, pageOffsets: [CGFloat]) -> CGFloat?
    func scrollPaginatedScrollTo(_ scrollView: UIScrollView, pageOffsets: [CGFloat], page: Int, animated: Bool)
}

// MARK: - Default / Stored Variable
extension ScrollPaginatedViewProtocol {

    public var paginatedCurrentPage: Int {
        get {
            return _currentPage
        }
        set {
            _currentPage = newValue
        }
    }
    
    private(set) var _currentPage: Int {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys._currentPage) as? Int) ?? 0
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys._currentPage, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - Function
public extension ScrollPaginatedViewProtocol {
    
    /// Making scroll paginated
    func scrollPaginatedViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>, oneByOne: Bool, pageOffsets: [CGFloat]) {
        if let pageOffset = self.pageOffset(
            for: scrollView.contentOffset.x,
            oneByOne: oneByOne,
            velocity: velocity.x,
            in: pageOffsets) {
            targetContentOffset.pointee.x = pageOffset
        }
    }
    
    /// For get scroll page index
    /// Call this function in scrollViewDidScroll(_:)
    func scrollPaginatedProgress(_ scrollView: UIScrollView, pageOffsets: [CGFloat]) -> CGFloat? {
        return self.pageFraction(
            for: scrollView.contentOffset.x,
            in: pageOffsets)
    }
    
    func scrollPaginatedScrollTo(_ scrollView: UIScrollView, pageOffsets: [CGFloat], page: Int, animated: Bool) {
        guard let offet = pageOffsets[safe: page] else {
            return
        }
        
        self.paginatedCurrentPage = page
        scrollView.setContentOffset(.init(x: offet, y: 0), animated: animated)
    }
}

// MARK: - Private
// Source : https://dev.to/elpassion/custom-pagination-in-uiscrollview-c45
extension ScrollPaginatedViewProtocol {
    
    /// Computes page offset from page offsets array for given scroll offset and velocity
    ///
    /// - Parameters:
    ///   - offset: current scroll offset
    ///   - oneByOne: scroll one page per page
    ///   - velocity: current scroll velocity
    ///   - pageOffsets: page offsets array
    /// - Returns: target page offset from array or nil if no page offets provided
    private func pageOffset(for offset: CGFloat, oneByOne: Bool,
                            velocity: CGFloat, in pageOffsets: [CGFloat]) -> CGFloat? {
        let pages = pageOffsets.enumerated().reduce([Int: CGFloat]()) {
            var dict = $0
            dict[$1.0] = $1.1
            return dict
        }
        
        guard let page = pages.min(by: { abs($0.1 - offset) < abs($1.1 - offset) }) else {
            return nil
        }
        
        if abs(velocity) < 0.2 {
            return page.value
        }
        
        let index = oneByOne ? self.paginatedCurrentPage : page.key
        if velocity < 0 {
            let newOffset = pages[pageOffsets.index(before: index)] ?? page.value
            if oneByOne {
                self.paginatedCurrentPage = self.paginatedCurrentPage == 0 ? 0 : self.paginatedCurrentPage - 1
            }
            return newOffset
        }
        
        let newOffset = pages[pageOffsets.index(after: index)] ?? page.value
        if oneByOne {
            self.paginatedCurrentPage += 1
        }
        return newOffset
    }

    /// Cumputes page fraction from page offsets array for given scroll offset
    ///
    /// - Parameters:
    ///   - offset: current scroll offset
    ///   - pageOffsets: page offsets array
    /// - Returns: current page fraction in range from 0 to number of pages or nil if no page offets provided
    private func pageFraction(for offset: CGFloat, in pageOffsets: [CGFloat]) -> CGFloat? {
        let pages = pageOffsets.sorted().enumerated()
        if let index = pages.first(where: { $0.1 == offset })?.0 {
            return CGFloat(index)
        }
        guard let nextOffset = pages.first(where: { $0.1 >= offset })?.1 else {
            return pages.map { $0.0 }.last.map { CGFloat($0) }
        }
        guard let (prevIdx, prevOffset) = pages.reversed().first(where: { $0.1 <= offset }) else {
            return pages.map { $0.0 }.first.map { CGFloat($0) }
        }
        return CGFloat(prevIdx) + (offset - prevOffset) / (nextOffset - prevOffset)
    }
}
