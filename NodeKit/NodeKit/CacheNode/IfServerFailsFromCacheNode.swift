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
    public var cacheReaderNode: any AsyncNode<URLNetworkRequest, Json>

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обработки.
    ///   - cacheReaderNode: Узел, считывающий данные из URL кэша.
    public init(next: any AsyncNode<URLRequest, Json>, cacheReaderNode: any AsyncNode<URLNetworkRequest, Json>) {
        self.next = next
        self.cacheReaderNode = cacheReaderNode
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
                let request = URLNetworkRequest(urlRequest: data)
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

    private func makeLog(with error: Error, from request: URLNetworkRequest) -> Log {
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