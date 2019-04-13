//
//  UrlDataResponse.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import Alamofire

/// Модель представления ответа сервера.
/// Используется для передачи информации внутри цепочки обработки ответа.
public struct UrlDataResponse {
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
}
