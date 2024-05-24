//
//  EtagReaderNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Этот узел читает eTag-токен из хранилища и добавляет его к запросу.
open class URLETagReaderNode: AsyncNode {

    // Следующий узел для обработки.
    public var next: any TransportLayerNode

    /// Ключ, по которому необходимо получить eTag-токен из хедеров.
    /// По-молчанию имеет значение `eTagRequestHeaderKey`
    public var etagHeaderKey: String

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обработки.
    ///   - eTagHeaderKey: Ключ, по которому необходимо добавить eTag-токен к запросу.
    public init(next: some TransportLayerNode,
                etagHeaderKey: String = ETagConstants.eTagRequestHeaderKey) {
        self.next = next
        self.etagHeaderKey = etagHeaderKey
    }

    /// Пытается прочесть eTag-токен из хранилища и добавить его к запросу.
    /// В случае, если прочесть токен не удалось, то управление просто передается дальше.
    open func process(
        _ data: TransportURLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Json> {
        await .withCheckedCancellation {
            guard
                let key = data.url.withOrderedQuery(),
                let tag = UserDefaults.etagStorage?.value(forKey: key) as? String
            else {
                return await next.process(data, logContext: logContext)
            }

            var headers = data.headers
            headers[self.etagHeaderKey] = tag

            let params = TransportURLParameters(method: data.method,
                                                url: data.url,
                                                headers: headers)

            let newData = TransportURLRequest(with: params, raw: data.raw)

            return await next.process(newData, logContext: logContext)
        }
    }
}
