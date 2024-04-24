//
//  RawDecodableMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public final class RawDecodableMock: RawDecodable {
    public typealias Raw = Json
    
    public init() { }
    
    public static var invokedFrom = false
    public static var invokedFromCount = 0
    public static var invokedFromParameter: Raw?
    public static var invokedFromParameterList: [Raw] = []
    public static var stubbedFromResult: Result<RawDecodableMock, Error>!
    
    public static func from(raw: Raw) throws -> RawDecodableMock {
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
    
    public static func flush() {
        invokedFrom = false
        invokedFromCount = 0
        invokedFromParameter = nil
        invokedFromParameterList = []
        stubbedFromResult = nil
    }
}
