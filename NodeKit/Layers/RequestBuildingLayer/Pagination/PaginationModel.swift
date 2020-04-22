//
//  PaginationModel.swift
//  NodeKit
//
//  Created by Alena Belyaeva on 22.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

/// Протокол для реализации моделей пагинации
/// За счет отсутсвия четкой структуры у api пагинаций - настраивать следует самостоятельно
/// - SeeAlso:
///     - `OffsetPaginationModel`
///     - `PagesPaginationModel`
///     - `CursorPaginationModel`
public protocol PaginationModel {

    /// Отвечает за то куда подставлять параметры отвечающие за пагинацию - query или body
    var encoding: ParametersEncoding { get }

    /// Параметры пагинации
    var parameters: [String: Any] { get }

    /// Метод позволяет пересчитать параметры для следующей страницы внутри модели
    func next(customIndexesUpdate: [String: Any])

    /// Метод позволяет сбросить параметры к начальному состоянию
    func renew()

}
