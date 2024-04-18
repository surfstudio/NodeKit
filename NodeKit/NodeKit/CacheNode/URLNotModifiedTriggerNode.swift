//
//  ETagRederNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Этот узел проверяет код ответа от сервера и в случае, если код равен 304 (NotModified)
/// Узел посылает запрос в URL кэш.
open class URLNotModifiedTriggerNode: AsyncNode {

    // MARK: - Properties

    /// Следующий узел для обратки.
    public var next: any ResponseProcessingLayerNode

    /// Узел для чтения данных из кэша.
    public var cacheReader: any AsyncNode<URLNetworkRequest, Json>

    // MARK: - Init and deinit

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обратки.
    ///   - cacheReader: Узел для чтения данных из кэша.
    public init(next: some ResponseProcessingLayerNode,
                cacheReader: some AsyncNode<URLNetworkRequest, Json>) {
        self.next = next
        self.cacheReader = cacheReader
    }

    // MARK: - Node

    /// Проверяет http status-code. Если код соовуетствует NotModified, то возвращает запрос из кэша.
    /// В протвином случае передает управление дальше.
    open func process(
        _ data: URLDataResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Json> {
        await .withCheckedCancellation {
            guard data.response.statusCode == 304 else {
                await logContext.add(makeErrorLog(code: data.response.statusCode))
                return await next.process(data, logContext: logContext)
            }

            await logContext.add(makeSuccessLog())

            return await cacheReader.process(
                URLNetworkRequest(urlRequest: data.request),
                logContext: logContext
            )
        }
    }

    // MARK: - Private Methods

    private func makeErrorLog(code: Int) -> Log {
        let msg = "Response status code = \(code) != 304 -> skip cache reading"
        return Log(
            logViewObjectName + msg,
            id: objectName
        )
    }

    private func makeSuccessLog() -> Log {
        let msg = "Response status code == 304 -> read cache"
        return Log(
            logViewObjectName + msg,
            id: objectName
        )
    }
}
