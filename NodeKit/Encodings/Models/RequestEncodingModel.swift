//
//  RequestEncodingModel.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 13.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

/// Модель слоя `Encoding`, собирает все данные для реквеста. Используется в `UrlRequestEncodingNode`
/// В качестве `Raw` принимает любые данные вида `BSON` или `JSON`
public struct RequestEncodingModel<Raw> {

    /// Параметры для формирования запроса.
    public let urlParameters: TransportUrlParameters
    /// Данные в виде `BSON` или `JSON`
    public let raw: Raw
    /// Кодировка данных запроса
    public let encoding: ParametersEncoding?

    /// Инцииаллизирует объект.
    /// - Parameter urlParameters: Параметры для формирования запроса.
    /// - Parameter raw: Данные в виде `BSON` или `JSON`
    /// - Parameter encoding: Кодировка данных запроса
    public init(urlParameters: TransportUrlParameters,
                raw: Raw,
                encoding: ParametersEncoding?) {
        self.urlParameters = urlParameters
        self.raw = raw
        self.encoding = encoding
    }

}
