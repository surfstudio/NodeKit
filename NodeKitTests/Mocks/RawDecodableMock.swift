//
//  RawDecodableMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class RawDecodableMock: RawDecodable {
    typealias Raw = Json
    
    static var invokedFrom = false
    static var invokedFromCount = 0
    static var invokedFromParameter: Raw?
    static var invokedFromParameterList: [Raw] = []
    static var stubbedFromResult: Result<RawDecodableMock, Error>!
    
    static func from(raw: Raw) throws -> RawDecodableMock {
        invokedFrom = true
        invokedFromCount += 1
        invokedFromParameter = raw
        invokedFromParameterList.append(raw)
        switch stubbedFromResult! {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        }
    }
    
    static func flush() {
        invokedFrom = false
        invokedFromCount = 0
        invokedFromParameter = nil
        invokedFromParameterList = []
        stubbedFromResult = nil
    }
}
