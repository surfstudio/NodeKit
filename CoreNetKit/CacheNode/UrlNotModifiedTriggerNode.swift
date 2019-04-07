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
open class UrlNotModifiedTriggerNode: ResponseProcessingLayerNode {

    // MARK: - Properties

    /// Следующий узел для обратки.
    public var next: ResponseProcessingLayerNode

    /// Узел для чтения данных из кэша.
    public var cacheReader: Node<UrlNetworkRequest, Json>

    // MARK: - Init and deinit

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обратки.
    ///   - cacheReader: Узел для чтения данных из кэша.
    public init(next: ResponseProcessingLayerNode,
                cacheReader: Node<UrlNetworkRequest, Json>) {
        self.next = next
        self.cacheReader = cacheReader
    }

    // MARK: - Node

    /// Проверяет http status-code. Если код соовуетствует NotModified, то возвращает запрос из кэша.
    /// В протвином случае передает управление дальше.
    open override func process(_ data: UrlDataResponse) -> Observer<Json> {

        var logMessage = self.logViewObjectName

        guard data.response.statusCode == 304 else {
            logMessage += "Response status code = \(data.response.statusCode) != 304 -> skip cache reading"
            return next.process(data).log(Log(logMessage, id: self.objectName))
        }
        logMessage += "Response status code == 304 -> read cache"
        return cacheReader.process(UrlNetworkRequest(urlRequest: data.request))
    }
}
