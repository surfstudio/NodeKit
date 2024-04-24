//
//  DTODecodableMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class DTODecodableMock: DTODecodable {
    typealias DTO = RawDecodableMock
    
    static var invokedFrom = false
    static var invokedFromCount = 0
    static var invokedFromParameter: RawDecodableMock?
    static var invokedFromParameterList: [RawDecodableMock] = []
    static var stubbedFromResult: Result<DTODecodableMock, Error>!
    
    static func from(dto: RawDecodableMock) throws -> DTODecodableMock {
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
    
    static func flush() {
        invokedFrom = false
        invokedFromCount = 0
        invokedFromParameter = nil
        invokedFromParameterList = []
        stubbedFromResult = nil
    }
}
