
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

    /// Определение теипа для `DTOConvertible.DTO`
    public typealias DTO = [String: Any]

    /// Провсто возвращет себя.
    /// - Throws: Не генерирует ошибок.
    public func toDTO() throws -> [String : Any] {
        return self
    }
}
