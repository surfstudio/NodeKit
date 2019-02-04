//
//  EmptyInputModel.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 01/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public struct EmptyModelEntry { }

extension EmptyModelEntry: RawMappable {

    public typealias Raw = Json

    public func toRaw() throws -> Json {
        return [:]
    }

    public static func toModel(from: Json) throws -> EmptyModelEntry {
        return EmptyModelEntry()
    }
}

public struct EmptyModel: DTOConvertible {

    public typealias DTO = EmptyModelEntry

    public func toDTO() throws -> EmptyModelEntry {
        return EmptyModelEntry()
    }

    public static func toModel(from: EmptyModelEntry) throws -> EmptyModel {
        return EmptyModel()
    }
}
