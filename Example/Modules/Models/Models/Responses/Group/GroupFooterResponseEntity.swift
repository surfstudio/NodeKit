//
//  GroupFooterResponseEntity.swift
//
//  Created by Andrei Frolov on 11.04.24.
//

import Foundation
import NodeKit

public struct GroupFooterResponseEntity {
    
    // MARK: - Properties
    
    public let text: String
    public let image: String
    
    // MARK: - Initialization
    
    public init(text: String, image: String) {
        self.text = text
        self.image = image
    }
}

extension GroupFooterResponseEntity: DTOConvertible {
    public typealias DTO = GroupFooterResponseEntry
    
    public func toDTO() throws -> GroupFooterResponseEntry {
        return GroupFooterResponseEntry(text: text, image: image)
    }
    
    public static func from(dto: GroupFooterResponseEntry) throws -> GroupFooterResponseEntity {
        return GroupFooterResponseEntity(text: dto.text, image: dto.image)
    }
}
