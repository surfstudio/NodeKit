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
open class IfConnectionFailedFromCacheNode: Node<RawUrlRequest, Json> {

    /// Следующий узел для обработки.
    public var next: Node<RawUrlRequest, Json>
    /// Узел, считывающий данные из URL кэша.
    public var cacheReaderNode: Node<UrlNetworkRequest, Json>

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обработки.
    ///   - cacheReaderNode: Узел, считывающий данные из URL кэша.
    public init(next: Node<RawUrlRequest, Json>, cacheReaderNode: Node<UrlNetworkRequest, Json>) {
        self.next = next
        self.cacheReaderNode = cacheReaderNode
    }

    /// Проверяет, произошла ли ошибка связи в ответ на запрос.
    /// Если ошибка произошла, то возвращает успешный ответ из кэша.
    /// В противном случае передает управление следующему узлу.
    open override func process(_ data: RawUrlRequest) -> Observer<Json> {

        return self.next.process(data).error { error in
            if error is BaseTechnicalError, let request = data.toUrlRequest() {
                return self.cacheReaderNode.process(request)
            }

            return .emit(error: error)
        }
    }

}
