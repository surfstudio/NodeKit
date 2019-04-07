//
//  UrlProcessedResponse.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import Alamofire

/// Используется для передачи данных внутри слоя постпроцессинга запроса.
public struct UrlProcessedResponse {

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

    /// JSON сериализованный после обработки ответа.
    public let json: Json

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - dataResponse: Модель полученная после обрабокти ответа.
    ///   - json: Сериализованный JSON
    public init(dataResponse: UrlDataResponse, json: Json) {
        self._dataResponse = dataResponse
        self.json = json
    }
}
