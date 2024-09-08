//
//  NSError+Extension.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 24/11/2021.
//

import Foundation
import Moya

extension NSError {
    
    enum GeengGoongErrorInternal: Int {
        case unknown = 1000
        case notAuthorized = 16000
        case noNetwork = 13000
    }
    
    static let domain = "fr.tharsan.app.Geeng-Goong"
    
    static func handleUnknownError(_ error: Error) -> NSError {
        if let moyaError = (error as? Moya.MoyaError), case .underlying(let aFError, _) = moyaError {
            let networkErrors = [NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet]
            if let AFCode = aFError.asAFError?.underlyingError, networkErrors.contains((AFCode as NSError).code) {
                return NSError.noNetwork()
            }
        }
        
        return NSError.unknownError()
    }
    
    static func noNetwork() -> NSError {
        let infos = self.userInfoWith(description: "No Network",
                                      failureReason: "No Network",
                                      suggestion: "")
        return NSError(domain: Self.domain,
                       code: GeengGoongErrorInternal.noNetwork.rawValue,
                       userInfo: infos)
    }
    
    static func unknownError() -> NSError {
        let infos = self.userInfoWith(description: "Unknown Error",
                                      failureReason: "Unknown Error",
                                      suggestion: "")
        return NSError(domain: Self.domain,
                       code: GeengGoongErrorInternal.unknown.rawValue,
                       userInfo: infos)
    }

    static func userInfoWith(description: String, failureReason: String, suggestion: String) -> [ String: String] {
        return [ NSLocalizedDescriptionKey: description,
                 NSLocalizedFailureReasonErrorKey: failureReason,
                 NSLocalizedRecoverySuggestionErrorKey: suggestion ]
    }
    
}
