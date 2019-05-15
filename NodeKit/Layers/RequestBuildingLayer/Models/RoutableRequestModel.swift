//
//  RoutableRequestModel.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Модель за проса в сеть.
/// Является промежуточным представлением.
/// Является следующим этапом после `RequestModel`
/// В дальнейшем ковнертируется в `EncodableRequestModel`
///
/// - SeeAlso:
///     - `RequestModel`
///     - `EncodableRequestModel`
public struct RoutableRequestModel<Route, Raw> {
    /// Метаданные
    public var metadata: [String: String]
    /// Данные для запроса в Raw
    public var raw: Raw
    /// Маршрут до удаленного метода
    public var route: Route
}
