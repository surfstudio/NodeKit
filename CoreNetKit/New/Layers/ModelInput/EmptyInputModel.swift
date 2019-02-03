//
//  EmptyInputModel.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 01/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public struct EmptyRequestEntry {
}

extension EmptyRequestEntry: RawMappable {

    public typealias Raw = Json

    public func toRaw() throws -> Json {
        return [:]
    }

    public static func toModel(from: Json) throws -> EmptyRequestEntry {
        return EmptyRequestEntry()
    }
}

struct EmptyRequest: DTOConvertible {

    public typealias DTO = EmptyRequestEntry

    public func toDTO() throws -> EmptyRequestEntry {
        return EmptyRequestEntry()
    }

    static func toModel(from: EmptyRequestEntry) throws -> EmptyRequest {
        return EmptyRequest()
    }
}
