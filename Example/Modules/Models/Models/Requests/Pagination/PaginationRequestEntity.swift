//
//  PaginationRequestEntity.swift
//
//  Created by Andrei Frolov on 11.04.24.
//

import NodeKit

public struct PaginationRequestEntity {
    
    // MARK: - Properties
    
    public let index: Int
    public let pageSize: Int
    
    // MARK: - Initialization
    
    public init(index: Int, pageSize: Int) {
        self.index = index
        self.pageSize = pageSize
    }
}

extension PaginationRequestEntity: DTOEncodable {
    public typealias DTO = PaginationRequestEntry
    
    public func toDTO() throws -> PaginationRequestEntry {
        PaginationRequestEntry(index: index, pageSize: pageSize)
    }
}
