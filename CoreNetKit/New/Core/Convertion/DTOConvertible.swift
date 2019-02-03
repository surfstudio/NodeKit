//
//  DTOConvertible.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol DTOConvertible {

    associatedtype DTO: RawMappable

    static func toModel(from: DTO) throws -> Self
    func toDTO() throws -> DTO
}

public enum ErrorArrayJsonMappiong: Error {
    case cantFindKeyInRaw(Json)
}

public enum MappingUtils {
    public static var arrayJsonKey = "_array"
}

extension Array: RawMappable where Element: RawMappable, Element.Raw == Json {

    public typealias Raw = Json

    public func toRaw() throws -> Json {
        let arrayData = try self.map { try $0.toRaw() }

        return [MappingUtils.arrayJsonKey: arrayData]
    }

    public static func toModel(from json: Json) throws -> Array<Element> {

        guard !json.isEmpty else {
            return [Element]()
        }

        guard let arrayData = json[MappingUtils.arrayJsonKey] as? [Json] else {
            throw ErrorArrayJsonMappiong.cantFindKeyInRaw(json)
        }

        return try arrayData.map { try Element.toModel(from: $0) }
    }
}

extension Array: DTOConvertible where Element: DTOConvertible, Element.DTO.Raw == Json {

    public typealias DTO = Array<Element.DTO>

    public static func toModel(from dto: DTO) throws -> Array<Element> {
        return try dto.map { try Element.toModel(from: $0) }
    }

    public func toDTO() throws -> DTO {
        return try self.map { try $0.toDTO() }
    }
}
