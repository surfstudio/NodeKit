//
//  TransportUrlParameters.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 16/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Модель для передачи параметров на транспортном сле цепочки.
public struct TransportUrlParameters {
    /// HTTP метод.
    public let method: Method
    /// URL эндпоинта.
    public let url: URL
    /// Хедеры запроса.
    public let headers: [String: String]
    /// Кодировка данных для запроса.
    public  let parametersEncoding: ParametersEncoding

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - method: HTTP метод.
    ///   - url: URL эндпоинта.
    ///   - headers: Хедеры запроса.
    ///   - parametersEncoding: Кодировка данных для запроса.
    public init(method: Method, url: URL, headers: [String: String] = [:], parametersEncoding: ParametersEncoding = .json) {
        self.method = method
        self.url = url
        self.headers = headers
        self.parametersEncoding = parametersEncoding
    }
}
