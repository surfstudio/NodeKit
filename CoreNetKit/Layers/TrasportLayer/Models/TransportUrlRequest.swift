//
//  TransportUrlRequest.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 16/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Модель для внутреннего представления запроса.
public struct TransportUrlRequest {

    /// HTTP метод.
    let method: Method
    /// URL эндпоинта.
    let url: URL
    /// Хедеры запроса.
    let headers: [String: String]
    /// Данные для запроса в формате `JSON`
    let raw: Json
    /// Кодировка данных для запроса.
    let parametersEncoding: ParametersEncoding

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - params: Параметры для формирования запроса.
    ///   - raw: Данные для запроса в формате `JSON`
    public init(with params: TransportUrlParameters, raw: Json) {
        self.method = params.method
        self.url = params.url
        self.headers = params.headers
        self.raw = raw
        self.parametersEncoding = params.parametersEncoding
    }
}
