//
//  HeaderInjectorNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation


/// This node allows adding any headers to the request.
open class HeaderInjectorNode: AsyncNode {

    /// The next node for processing.
    public var next: any TransportLayerNode

    /// Headers to be added.
    public var headers: [String: String]

    /// Initializer.
    ///
    /// - Parameters:
    ///   - next: The next node for processing.
    ///   - headers: Headers to be added.
    public init(next: some TransportLayerNode, headers: [String: String]) {
        self.next = next
        self.headers = headers
    }

    /// Adds headers to the request and sends it to the next node in the chain.
    open func process(
        _ data: TransportURLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Json> {
        await .withCheckedCancellation {
            var resultHeaders = headers
            var log = logViewObjectName
            log += "Add headers \(headers)" + .lineTabDeilimeter
            log += "To headers \(data.headers)" + .lineTabDeilimeter
            data.headers.forEach { resultHeaders[$0.key] = $0.value }
            let newData = TransportURLRequest(
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
}
