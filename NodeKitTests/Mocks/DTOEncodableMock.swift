//
//  DTOEncodableMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class DTOEncodableMock<DTO: RawEncodable>: DTOEncodable {
    
    var invokedToDTO = false
    var invokedToDTOCount = 0
    var stubbedToDTOResult: Result<DTO, Error>!
    
    func toDTO() throws -> DTO {
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
