//
//  RawMappableMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public final class RawMappableMock: RawMappable {
    public typealias Raw = Json
    
    public init() { }
    
    public static var invokedFrom = false
    public static var invokedFromCount = 0
    public static var invokedFromParameter: Json?
    public static var invokedFromParameterList: [Json] = []
    public static var stubbedFromResult: Result<RawMappableMock, Error>!
    
    public static func from(raw: Json) throws -> RawMappableMock {
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
    
    public var invokedToRaw = false
    public var invokedToRawCount = 0
    public var stubbedToRawResult: Result<Json, Error>!
    
    public func toRaw() throws -> Json {
        invokedToRaw = true
        invokedToRawCount += 1
        switch stubbedToRawResult! {
        case .success(let raw):
            return raw
        case .failure(let error):
            throw error
        }
    }
    
    public static func flush() {
        invokedFrom = false
        invokedFromCount = 0
        invokedFromParameter = nil
        invokedFromParameterList = []
        stubbedFromResult = nil
    }
}
