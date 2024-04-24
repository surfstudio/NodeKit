//
//  RawEncodableMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public class RawEncodableMock<Raw>: RawEncodable {
    
    public init() { }
    
    public var invokedToRaw = false
    public var invokedToRawCount = 0
    public var stubbedToRawResult: Result<Raw, Error>!
    
    public func toRaw() throws -> Raw {
        invokedToRaw = true
        invokedToRawCount += 1
        switch stubbedToRawResult! {
        case .success(let raw):
            return raw
        case .failure(let error):
            throw error
        }
    }
}
