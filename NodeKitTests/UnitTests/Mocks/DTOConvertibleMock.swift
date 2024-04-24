//
//  DTOConvertibleMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class DTOConvertibleMock: DTOConvertible {
    typealias DTO = RawMappableMock
    
    static var invokedFrom = false
    static var invokedFromCount = 0
    static var invokedFromParameter: RawMappableMock?
    static var invokedFromParameterList: [RawMappableMock] = []
    static var stubbedFromResult: Result<DTOConvertibleMock, Error>!
    
    static func from(dto: RawMappableMock) throws -> DTOConvertibleMock {
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
    
    var invokedToDTO = false
    var invokedToDTOCount = 0
    var stubbedToDTOResult: Result<RawMappableMock, Error>!
    
    func toDTO() throws -> RawMappableMock {
        invokedToDTO = true
        invokedToDTOCount += 1
        switch stubbedToDTOResult! {
        case .success(let dto):
            return dto
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
