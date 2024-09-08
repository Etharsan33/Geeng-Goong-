//
//  PersistenceError.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 25/01/2022.
//

import Foundation

enum PersistenceError: Error {
    case insertionFailed
    case fetchItemsFailed
    case deletionFailed
    case addNewItemFailed
}
