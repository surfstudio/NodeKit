//
//  DTOConvertibleMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public final class DTOConvertibleMock: DTOConvertible {
    public typealias DTO = RawMappableMock
    
    public init() { }
    
    public static var invokedFrom = false
    public static var invokedFromCount = 0
    public static var invokedFromParameter: RawMappableMock?
    public static var invokedFromParameterList: [RawMappableMock] = []
    public static var stubbedFromResult: Result<DTOConvertibleMock, Error>!
    
    public static func from(dto: RawMappableMock) throws -> DTOConvertibleMock {
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
    
    public var invokedToDTO = false
    public var invokedToDTOCount = 0
    public var stubbedToDTOResult: Result<RawMappableMock, Error>!
    
    public func toDTO() throws -> RawMappableMock {
        invokedToDTO = true
        invokedToDTOCount += 1
        switch stubbedToDTOResult! {
        case .success(let dto):
            return dto
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
