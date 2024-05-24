//
//  CachePreprocessor.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Ошибки для узла `FirstCachePolicyNode`
///
/// - SeeAlso: `FirstCachePolicyNode`
///
/// - cantGetURLRequest: Возникает в случае, если запрос отправленный в сеть не содержит `URLRequest`
enum BaseFirstCachePolicyNodeError: Error {
    case cantGetURLRequest
}

/// Этот узел реализует политику кэширования
/// "Сначала читаем из кэша, а затем запрашиваем у сервера"
/// - Important: В общем случае слушатель может быть оповещен дважды. Первый раз, когда ответ прочитан из кэша, а второй раз, когда он был получен с сервера.
class FirstCachePolicyNode: AsyncStreamNode {
    // MARK: - Nested

    /// Тип для читающего из URL кэша узла
    typealias CacheReaderNode = AsyncNode<URLNetworkRequest, Json>

    /// Тип для следующего узла
    typealias NextProcessorNode = AsyncNode<RawURLRequest, Json>

    // MARK: - Properties

    /// Следующий узел для обработки.
    var next: any NextProcessorNode

    /// Узел для чтения из кэша.
    var cacheReaderNode: any CacheReaderNode

    // MARK: - Init and Deinit

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - cacheReaderNode: Узел для чтения из кэша.
    ///   - next: Следующий узел для обработки.
    init(cacheReaderNode: any CacheReaderNode, next: any NextProcessorNode) {
        self.cacheReaderNode = cacheReaderNode
        self.next = next
    }

    // MARK: - Node
    
    /// Пытается получить `URLRequest` и если удается, то обращается в кэш
    /// а затем, передает управление следующему узлу.
    /// В случае, если получить `URLRequest` не удалось,
    /// то управление просто передается следующему узлу
    func process(
        _ data: RawURLRequest,
        logContext: LoggingContextProtocol
    ) -> AsyncStream<NodeResult<Json>> {
        return AsyncStream { continuation in
            let task = Task {
                if let request = data.toURLRequest() {
                    let cacheResult = await cacheReaderNode.process(request, logContext: logContext)
                    continuation.yield(cacheResult)
                }
                
                let nextResult = await next.process(data, logContext: logContext)
                continuation.yield(nextResult)
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
