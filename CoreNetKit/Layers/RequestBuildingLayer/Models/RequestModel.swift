//
//  RequestModel.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Модель для запроса в сеть.
/// Является промежуточным представленияем для передачи данных внутри цепочки.
/// В дальнейшем конвертируется в `RoutableRequestModel`
///
/// - SeeAlso: `RoutableRequestModel`
public struct RequestModel<Raw> {
    /// Метаданные
    public var metadata: [String: String]
    /// Данные для запроса
    public var raw: Raw
}
