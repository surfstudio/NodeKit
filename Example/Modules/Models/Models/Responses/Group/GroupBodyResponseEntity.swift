//
//  GroupBodyResponseEntity.swift
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation
import NodeKit

public struct GroupBodyResponseEntity {
    
    // MARK: - Properties
    
    public let text: String
    public let image: String
    
    // MARK: - Initialization
    
    public init(text: String, image: String) {
        self.text = text
        self.image = image
    }
}

extension GroupBodyResponseEntity: DTOConvertible {
    public typealias DTO = GroupBodyResponseEntry
    
    public func toDTO() throws -> GroupBodyResponseEntry {
        return GroupBodyResponseEntry(text: text, image: image)
    }
    
    public static func from(dto: GroupBodyResponseEntry) throws -> GroupBodyResponseEntity {
        return GroupBodyResponseEntity(text: dto.text, image: dto.image)
    }
}
