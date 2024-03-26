//
//  UrlDataResponse.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Модель представления ответа сервера.
/// Используется для передачи информации внутри цепочки обработки ответа.
public struct UrlDataResponse: Equatable {
    /// Запрос, отправленный на сервер.
    public let request: URLRequest
    /// Ответ, полученный от сервера
    public let response: HTTPURLResponse
    /// Данные, возвращенные сервером.
    public let data: Data
    /// Метрики запроса.
    public let metrics: URLSessionTaskMetrics?
    /// Время, затраченное на сериализацию овтета. 
    public let serializationDuration: TimeInterval

    public init(request: URLRequest,
                response: HTTPURLResponse,
                data: Data,
                metrics: URLSessionTaskMetrics?,
                serializationDuration: TimeInterval) {
        self.request = request
        self.response = response
        self.data = data
        self.metrics = metrics
        self.serializationDuration = serializationDuration
    }
}
