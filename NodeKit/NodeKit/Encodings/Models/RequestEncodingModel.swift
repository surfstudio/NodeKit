//
//  RequestEncodingModel.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 13.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

/// Model of the `Encoding` layer, gathers all data for the request. Used in ``URLJsonRequestEncodingNode``.
public struct RequestEncodingModel {

    /// Параметры для формирования запроса.
    public let urlParameters: TransportURLParameters
    /// Данные в виде `BSON` или `JSON`
    public let raw: Json
    /// Кодировка данных запроса
    public let encoding: ParametersEncoding?

    /// Инцииаллизирует объект.
    /// - Parameter urlParameters: Параметры для формирования запроса.
    /// - Parameter raw: Данные в виде `JSON`
    /// - Parameter encoding: Кодировка данных запроса
    public init(urlParameters: TransportURLParameters,
                raw: Json,
                encoding: ParametersEncoding?) {
        self.urlParameters = urlParameters
        self.raw = raw
        self.encoding = encoding
    }

}
