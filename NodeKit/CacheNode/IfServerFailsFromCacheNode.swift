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
@available(iOS 13.0, *)
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
    open override func process(_ data: URLRequest) async -> Result<Json, Error> {
        return await next.process(data)
            .flatMapError { error in
                let request = UrlNetworkRequest(urlRequest: data)
                if error is BaseTechnicalError {
                    return await cacheReaderNode.process(request)
                }
                return .failure(error)
            }
    }

}
