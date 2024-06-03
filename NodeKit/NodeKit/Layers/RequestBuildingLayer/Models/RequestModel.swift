//
//  RequestModel.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Model for network request.
/// It serves as an intermediate representation for passing data within the chain.
/// It is subsequently converted into ``RoutableRequestModel``.
public struct RequestModel<Raw> {
    /// Метаданные
    public var metadata: [String: String]
    /// Данные для запроса
    public var raw: Raw
}
