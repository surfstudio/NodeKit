//
//  Array_RawMappable.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

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
