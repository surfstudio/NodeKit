//
//  IfServerFailsFromCacheNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Узел реализует политику кэширования "Если интернета нет, то запросить данные из кэша"
/// Этот узел работает с URL кэшом.
open class IfConnectionFailedFromCacheNode: Node<URLRequest, Json> {

    /// Следующий узел для обработки.
    public var next: Node<URLRequest, Json>
    /// Узел, считывающий данные из URL кэша.
    public var cacheReaderNode: Node<UrlNetworkRequest, Json>

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обработки.
    ///   - cacheReaderNode: Узел, считывающий данные из URL кэша.
    public init(next: Node<URLRequest, Json>, cacheReaderNode: Node<UrlNetworkRequest, Json>) {
        self.next = next
        self.cacheReaderNode = cacheReaderNode
    }

    /// Проверяет, произошла ли ошибка связи в ответ на запрос.
    /// Если ошибка произошла, то возвращает успешный ответ из кэша.
    /// В противном случае передает управление следующему узлу.
    open override func process(_ data: URLRequest) -> Observer<Json> {

        return self.next.process(data).mapError { error -> Observer<Json> in
            var logMessage = self.logViewObjectName
            logMessage += "Catching \(error)" + .lineTabDeilimeter
            if error is BaseTechnicalError {
                logMessage += "Start read cache" + .lineTabDeilimeter
                return self.cacheReaderNode.process(UrlNetworkRequest(urlRequest: data))
            }
            logMessage += "Error is \(type(of: error))"
            logMessage += "and request = \(String(describing: UrlNetworkRequest(urlRequest: data)))" + .lineTabDeilimeter
            logMessage += "-> throw error"
            return .emit(error: error)
        }
    }

}
