//
//  Sequence+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by Elankumaran Tharsan on 18/07/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import Foundation

public extension Sequence where Element: Hashable {

    /// Return the sequence with all duplicates removed. Order be maintain
    ///
    /// i.e. `[ 1, 2, 3, 1, 2 ].uniqued() == [ 1, 2, 3 ]`
    ///
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return self.filter { seen.insert($0).inserted }
    }
}
