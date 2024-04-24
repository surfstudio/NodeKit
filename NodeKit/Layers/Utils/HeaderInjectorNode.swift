//
//  HeaderInjectorNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation


/// Этот узел позволяет добавить любые хедеры в запрос.
/// - SeeAlso: TransportLayerNode
open class HeaderInjectorNode: AsyncNode {

    /// Следующий в цепочке узел.
    public var next: any TransportLayerNode

    /// Хедеры, которые необходимо добавить.
    public var headers: [String: String]

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следующий в цепочке узел.
    ///   - headers: Хедеры, которые необходимо добавить.
    public init(next: some TransportLayerNode, headers: [String: String]) {
        self.next = next
        self.headers = headers
    }

    /// Добавляет хедеры к запросу и отправляет его слудующему в цепочке узлу.
    open func process(
        _ data: TransportUrlRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Json> {
        var resultHeaders = headers
        var log = logViewObjectName
        log += "Add headers \(headers)" + .lineTabDeilimeter
        log += "To headers \(data.headers)" + .lineTabDeilimeter
        data.headers.forEach { resultHeaders[$0.key] = $0.value }
        let newData = TransportUrlRequest(
            method: data.method,
            url: data.url,
            headers: resultHeaders,
            raw: data.raw
        )
        log += "Result headers: \(resultHeaders)"
        await logContext.add(Log(log, id: objectName))
        return await next.process(newData, logContext: logContext)
    }
}
