//
//  DTODecodableMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public final class DTODecodableMock: DTODecodable {
    public typealias DTO = RawDecodableMock
    
    public init() { }
    
    public static var invokedFrom = false
    public static var invokedFromCount = 0
    public static var invokedFromParameter: RawDecodableMock?
    public static var invokedFromParameterList: [RawDecodableMock] = []
    public static var stubbedFromResult: Result<DTODecodableMock, Error>!
    
    public static func from(dto: RawDecodableMock) throws -> DTODecodableMock {
        invokedFrom = true
        invokedFromCount += 1
        invokedFromParameter = dto
        invokedFromParameterList.append(dto)
        switch stubbedFromResult! {
        case .success(let value):
            return value
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
