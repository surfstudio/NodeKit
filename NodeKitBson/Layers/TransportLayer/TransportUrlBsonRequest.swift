//  TransportUrlBsonRequest.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 02.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation
import NodeKit

/// Модель для внутреннего представления запроса.
public struct TransportUrlBsonRequest {

    /// HTTP метод.
    public let method: NodeKit.Method
    /// URL эндпоинта.
    public let url: URL
    /// Хедеры запроса.
    public let headers: [String: String]
    /// Данные для запроса в формате `JSON`
    public let raw: Bson

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - params: Параметры для формирования запроса.
    ///   - raw: Данные для запроса в формате `BSON`
    public init(with params: TransportUrlParameters, raw: Bson) {
        self.init(method: params.method,
                  url: params.url,
                  headers: params.headers,
                  raw: raw)
    }

    public init(method: NodeKit.Method,
                url: URL,
                headers: [String: String],
                raw: Bson) {
        self.method = method
        self.url = url
        self.headers = headers
        self.raw = raw
    }

}
