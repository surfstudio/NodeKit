//
//  PaginationResponseEntity.swift
//
//  Created by Andrei Frolov on 11.04.24.
//

import NodeKit

public struct PaginationResponseEntity {
    
    // MARK: - Properties
    
    public let name: String
    public let image: String
    
    // MARK: - Initialization
    
    public init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}

extension PaginationResponseEntity: DTOConvertible {
    public typealias DTO = PaginationResponseEntry
    
    public static func from(dto: PaginationResponseEntry) throws -> PaginationResponseEntity {
        return PaginationResponseEntity(name: dto.name, image: dto.image)
    }
    
    public func toDTO() throws -> PaginationResponseEntry {
        return PaginationResponseEntry(name: name, image: image)
    }
}
