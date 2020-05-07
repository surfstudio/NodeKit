//
//  UrlProcessedResponse.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Используется для передачи данных внутри слоя постпроцессинга запроса.
public struct UrlProcessedResponse<Type> {

    private let _dataResponse: UrlDataResponse

    /// URL запрос, отправленный серверу.
    public var request: URLRequest {
        return self._dataResponse.request
    }

    /// Ответ, полученный от сервера.
    public var response: HTTPURLResponse {
        return self._dataResponse.response
    }

    /// Метрики запроса.
    public var metrics: URLSessionTaskMetrics? {
        return self._dataResponse.metrics
    }

    /// Время, затраченное на сериализацию овтета.
    public var serializationDuration: TimeInterval {
        return self._dataResponse.serializationDuration
    }

    /// Ответ, возвращенный сервером.
    public var data: Data {
        return self._dataResponse.data
    }

    /// JSON/BSON сериализованный после обработки ответа.
    public let type: Type

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - dataResponse: Модель полученная после обрабокти ответа.
    ///   - type: Сериализованный JSON/BSON
    public init(dataResponse: UrlDataResponse, type: Type) {
        self._dataResponse = dataResponse
        self.type = type
    }
}
