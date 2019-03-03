//
//  EmptyInputModel.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 01/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// RawMappable Trick (:
public struct EmptyModelEntry {
    public init() {}
}

extension EmptyModelEntry: RawMappable {

    public typealias Raw = Json

    public func toRaw() throws -> Json {
        return [:]
    }

    public static func toModel(from: Json) throws -> EmptyModelEntry {
        return EmptyModelEntry()
    }
}

/// Trick provides possibility to send/recive empty request/response
public struct EmptyModel {
    public init() {}
}

extension EmptyModel: DTOConvertible {

    public typealias DTO = EmptyModelEntry

    public func toDTO() throws -> EmptyModelEntry {
        return EmptyModelEntry()
    }

    public static func toModel(from: EmptyModelEntry) throws -> EmptyModel {
        return EmptyModel()
    }
}

// MARK: - NodeProtocol with EmptyModel

extension NodeProtocol where Input == EmptyModel {
    public func process() -> Observer<Output> {
        return self.process(EmptyModel())
    }
}
