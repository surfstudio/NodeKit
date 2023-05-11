//
//  RawBsonMappable.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 17.06.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//
import Foundation
import BSON
import NodeKit

/// Объект содержащий словарь примитивов
public typealias Bson = Document

/// Имплементация протокола для `BSON` мапинга
extension Document: RawMappable {
    public static func from(raw: Bson) throws -> Document {
        return raw
    }

    public func toRaw() throws -> Bson {
        return self
    }

    public typealias Raw = Bson
}
