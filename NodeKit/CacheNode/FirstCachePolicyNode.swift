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
/// - cantGetUrlRequest: Возникает в случае, если запрос отправленный в сеть не содержит `UrlRequest`
public enum BaseFirstCachePolicyNodeError: Error {
    case cantGetUrlRequest
}

/// Этот узел реализует политику кэширования
/// "Сначала читаем из кэша, а затем запрашиваем у сервера"
/// - Important: В ообщем случае слушатель может быть оповещен дважды. Первый раз, когда ответ прочитан из кэша, а второй раз, когда он был получен с сервера.
open class FirstCachePolicyNode: Node {

    // MARK: - Nested

    /// Тип для читающего из URL кэша узла
    public typealias CacheReaderNode = Node<UrlNetworkRequest, Json>

    /// Тип для следующего узла
    public typealias NextProcessorNode = Node<RawUrlRequest, Json>

    // MARK: - Properties

    /// Следующий узел для обработки.
    public var next: any NextProcessorNode

    /// Узел для чтения из кэша.
    public var cacheReaderNode: any CacheReaderNode

    // MARK: - Init and Deinit

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - cacheReaderNode: Следующий узел для обработки.
    ///   - next: Узел для чтения из кэша.
    public init(cacheReaderNode: any CacheReaderNode, next: any NextProcessorNode) {
        self.cacheReaderNode = cacheReaderNode
        self.next = next
    }

    // MARK: - Node

    /// Пытается получить `URLRequest` и если удается, то обращается в кэш
    /// а затем, передает управление следующему узлу.
    /// В случае, если получить `URLRequest` не удалось,
    /// то управление просто передается следующему узлу
    open func process(_ data: RawUrlRequest) -> Observer<Json> {
        let result = Context<Json>()

        if let request = data.toUrlRequest() {
            cacheReaderNode.process(request)
                .onCompleted { result.emit(data: $0) }
                .onError { result.emit(error: $0)}
        }

        next.process(data)
            .onCompleted { result.emit(data: $0)}
            .onError { result.emit(error: $0) }

        return result
    }

}
