//
//  GroupHeaderResponseEntity.swift
//
//  Created by Andrei Frolov on 11.04.24.
//

import Foundation
import NodeKit

public struct GroupHeaderResponseEntity {
    
    // MARK: - Properties
    
    public let text: String
    public let image: String
    
    // MARK: - Initialization
    
    public init(text: String, image: String) {
        self.text = text
        self.image = image
    }
}

extension GroupHeaderResponseEntity: DTOConvertible {
    public typealias DTO = GroupHeaderResponseEntry
    
    public func toDTO() throws -> GroupHeaderResponseEntry {
        return GroupHeaderResponseEntry(text: text, image: image)
    }
    
    public static func from(dto: GroupHeaderResponseEntry) throws -> GroupHeaderResponseEntity {
        return GroupHeaderResponseEntity(text: dto.text, image: dto.image)
    }
}
