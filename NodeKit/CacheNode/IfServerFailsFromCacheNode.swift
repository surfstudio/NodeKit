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
open class IfConnectionFailedFromCacheNode: AsyncNode {

    /// Следующий узел для обработки.
    public var next: any AsyncNode<URLRequest, Json>
    /// Узел, считывающий данные из URL кэша.
    public var cacheReaderNode: any AsyncNode<UrlNetworkRequest, Json>

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обработки.
    ///   - cacheReaderNode: Узел, считывающий данные из URL кэша.
    public init(next: any AsyncNode<URLRequest, Json>, cacheReaderNode: any AsyncNode<UrlNetworkRequest, Json>) {
        self.next = next
        self.cacheReaderNode = cacheReaderNode
    }

    /// Проверяет, произошла ли ошибка связи в ответ на запрос.
    /// Если ошибка произошла, то возвращает успешный ответ из кэша.
    /// В противном случае передает управление следующему узлу.
    open func process(_ data: URLRequest) -> Observer<Json> {

        return self.next.process(data).mapError { error -> Observer<Json> in
            var logMessage = self.logViewObjectName
            logMessage += "Catching \(error)" + .lineTabDeilimeter
            let request = UrlNetworkRequest(urlRequest: data)
            if error is BaseTechnicalError {
                logMessage += "Start read cache" + .lineTabDeilimeter
                return self.cacheReaderNode.process(request)
            }
            logMessage += "Error is \(type(of: error))"
            logMessage += "and request = \(String(describing: request))" + .lineTabDeilimeter
            logMessage += "-> throw error"
            return .emit(error: error)
        }
    }

    /// Проверяет, произошла ли ошибка связи в ответ на запрос.
    /// Если ошибка произошла, то возвращает успешный ответ из кэша.
    /// В противном случае передает управление следующему узлу.
    open func process(
        _ data: URLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Json> {
        return await next.process(data, logContext: logContext)
            .asyncFlatMapError { error in
                let request = UrlNetworkRequest(urlRequest: data)
                if error is BaseTechnicalError {
                    await logContext.add(makeBaseTechinalLog(with: error))
                    return await cacheReaderNode.process(request, logContext: logContext)
                }
                await logContext.add(makeLog(with: error, from: request))
                return .failure(error)
            }
    }

    // MARK: - Private Method

    private func makeBaseTechinalLog(with error: Error) -> Log {
        return Log(
            logViewObjectName + 
                "Catching \(error)" + .lineTabDeilimeter +
                "Start read cache" + .lineTabDeilimeter,
            id: objectName
        )
    }

    private func makeLog(with error: Error, from request: UrlNetworkRequest) -> Log {
        return Log(
            logViewObjectName +
                "Catching \(error)" + .lineTabDeilimeter +
                "Error is \(type(of: error))" +
                "and request = \(String(describing: request))" + .lineTabDeilimeter +
                "-> throw error",
            id: objectName
        )
    }

}
