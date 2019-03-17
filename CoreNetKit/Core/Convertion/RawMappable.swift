//
//  RawMappable.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

/// Описывает сущность из нижнего слоя DTO.
/// Может конвертировать себя в RAW (например JSON) и конвертировать RAW в себя.
public protocol RawMappable {

    /// Тип данных, в которые мапятся модели. Напрмиер JSON
    associatedtype Raw

    /// Конвертирет модель в RAW
    /// - Returns: RAW-представление модели
    /// - Throws: Могут возникать любые исключения, определенные пользователем.
    func toRaw() throws -> Raw

    /// Преобразует данные в RAW формате в модель.
    ///
    /// - Parameter from: Данные в RAW формате
    /// - Returns: модель полученная из RAW
    /// - Throws: Могут возникать любые исключения, определенные пользователем.
    static func toModel(from: Raw) throws -> Self
}
