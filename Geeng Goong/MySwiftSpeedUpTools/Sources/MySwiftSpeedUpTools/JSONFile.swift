//
//  JSONFile.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 24/05/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import Foundation

public struct JSONFile {
    
    private var fileName: String!
    
    public init(fileName: String) {
        self.fileName = fileName
    }
    
    public func getData() -> Data {
        let path = Bundle.main.path(forResource: self.fileName, ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        return data
    }
    
    public func decode<T: Decodable>(_ decodable: T.Type, dateStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) -> Result<T, Error> {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateStrategy
            let decode = try decoder.decode(decodable, from: self.getData())
            return .success(decode)
        } catch {
            return .failure(error)
        }
    }
}
