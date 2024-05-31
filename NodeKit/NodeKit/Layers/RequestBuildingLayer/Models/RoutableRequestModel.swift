//
//  RoutableRequestModel.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Model for network request.
/// It serves as an intermediate representation.
/// It is the next stage after ``RequestModel``.
/// It is subsequently converted into ``EncodableRequestModel``.
public struct RoutableRequestModel<Route, Raw> {
    /// Метаданные
    public var metadata: [String: String]
    /// Данные для запроса в Raw
    public var raw: Raw
    /// Маршрут до удаленного метода
    public var route: Route
}
