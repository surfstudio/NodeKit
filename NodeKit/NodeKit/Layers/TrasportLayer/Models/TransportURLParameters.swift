//
//  TransportURLParameters.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 16/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Модель для передачи параметров на транспортном слое цепочки.
public struct TransportURLParameters {
    /// HTTP метод.
    public let method: Method
    /// URL эндпоинта.
    public let url: URL
    /// Хедеры запроса.
    public let headers: [String: String]

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - method: HTTP метод.
    ///   - url: URL эндпоинта.
    ///   - headers: Хедеры запроса.
    public init(method: Method, url: URL, headers: [String: String] = [:]) {
        self.method = method
        self.url = url
        self.headers = headers
    }

}
