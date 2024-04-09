//
//  RawMappableMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class RawMappableMock: RawMappable {
    typealias Raw = Json
    
    static var invokedFrom = false
    static var invokedFromCount = 0
    static var invokedFromParameter: Json?
    static var invokedFromParameterList: [Json] = []
    static var stubbedFromResult: Result<RawMappableMock, Error>!
    
    static func from(raw: Json) throws -> RawMappableMock {
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
    
    var invokedToRaw = false
    var invokedToRawCount = 0
    var stubbedToRawResult: Result<Json, Error>!
    
    func toRaw() throws -> Json {
        invokedToRaw = true
        invokedToRawCount += 1
        switch stubbedToRawResult! {
        case .success(let raw):
            return raw
        case .failure(let error):
            throw error
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
