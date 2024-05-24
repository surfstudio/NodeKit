//
//  URLDataResponse.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Модель представления ответа сервера.
/// Используется для передачи информации внутри цепочки обработки ответа.
public struct URLDataResponse: Equatable {
    /// Запрос, отправленный на сервер.
    public let request: URLRequest
    /// Ответ, полученный от сервера
    public let response: HTTPURLResponse
    /// Данные, возвращенные сервером.
    public let data: Data

    public init(request: URLRequest,
                response: HTTPURLResponse,
                data: Data) {
        self.request = request
        self.response = response
        self.data = data
    }
}
