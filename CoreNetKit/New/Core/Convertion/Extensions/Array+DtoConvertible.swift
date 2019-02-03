//
//  Array+DtoCOnvertible.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

extension Array: DTOConvertible where Element: DTOConvertible, Element.DTO.Raw == Json {

    public typealias DTO = Array<Element.DTO>

    public static func toModel(from dto: DTO) throws -> Array<Element> {
        return try dto.map { try Element.toModel(from: $0) }
    }

    public func toDTO() throws -> DTO {
        return try self.map { try $0.toDTO() }
    }
}
