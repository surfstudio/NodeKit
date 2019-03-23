//
//  DTOConvertible.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

/// Описывает сущность из верхнего слоя DTO.
/// Может конвертировать себя в нижний слой DTO и конвертировать нижнйи слой DTO в себя.
public protocol DTOConvertible {

    /// Следующий слой DTO
    associatedtype DTO: RawMappable

    /// Кнвертирует модель из DTO нижнего уровня в DTO-модель верхнего уровня.
    ///
    /// - Parameter from: Модель нижнего уровня DTO из которой необходимо получить модель верхнего уровня.
    /// - Returns: Результат конвертирования.
    /// - Throws: Могут возникать любе исключения, определенные пользователем.
    static func toModel(from: DTO) throws -> Self

    /// Получает DTO-модель нижнего уровня из себя.
    ///
    /// - Returns: Результат конвертирования.
    /// - Throws: Могут возникать любе исключения, определенные пользователем.
    func toDTO() throws -> DTO
}
