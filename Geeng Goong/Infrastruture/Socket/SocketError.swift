//
//  SocketError.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 14/01/2022.
//

import Foundation

enum SocketError: Error {
    case socketNotConnected
    case error(code: String, message: String?)
    case jsonNotValid
    case mappingError
    case unknown
}
