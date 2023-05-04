//
//  DTOConvertible+Document.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 03.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//
import Foundation
import BSON

extension Bson: DTOConvertible {

    public typealias DTO = Bson

    public func toDTO() throws -> Bson {
        return self
    }

    public static func from(dto: Bson) throws -> Document {
        return dto
    }

}
