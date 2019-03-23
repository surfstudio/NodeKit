//
//  EncodableRequestModel.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Модель для запроса в сеть.
/// Является обобщенным представлениям любого запроса.
/// Является следующим этапом после `RoutableRequestModel`
///
/// - SeeAlso:
///     - `RoutableRequestModel`
///     - `EncodableRequestModel`
public struct EncodableRequestModel<Route, Raw, Encoding> {
    /// Метаданные
    public var metadata: [String: String]
    /// Данные для запроса в Raw
    public var raw: Raw
    /// Маршрут до удаленного метода
    public var route: Route
    /// Кодировка данных запроса
    public var encoding: Encoding
}
