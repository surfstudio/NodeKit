
//
//  File.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 23/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Это расширение позволяет представлять словарь как DTOConvertible в случае если словарь это Json
extension Dictionary: DTOConvertible where Dictionary.Key == String, Dictionary.Value == Any {

    public typealias DTO = Json

    public func toDTO() throws -> Json {
        return self
    }

    public static func from(dto: Json) throws -> [String: Any] {
        return dto
    }
}
