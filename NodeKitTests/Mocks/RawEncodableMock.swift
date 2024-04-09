//
//  RawEncodableMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class RawEncodableMock<Raw>: RawEncodable {
    
    var invokedToRaw = false
    var invokedToRawCount = 0
    var stubbedToRawResult: Result<Raw, Error>!
    
    func toRaw() throws -> Raw {
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
