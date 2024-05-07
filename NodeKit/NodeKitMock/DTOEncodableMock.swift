//
//  DTOEncodableMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public class DTOEncodableMock<DTO: RawEncodable>: DTOEncodable {
    
    public init() { }
    
    public var invokedToDTO = false
    public var invokedToDTOCount = 0
    public var stubbedToDTOResult: Result<DTO, Error>!
    
    public func toDTO() throws -> DTO {
        invokedToDTO = true
        invokedToDTOCount += 1
        switch stubbedToDTOResult! {
        case .success(let dto):
            return dto
        case .failure(let error):
            throw error
        }
    }
}
