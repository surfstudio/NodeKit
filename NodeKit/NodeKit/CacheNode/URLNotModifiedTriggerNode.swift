//
//  ETagRederNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// This node checks the server response code and if the code is `304 (Not Modified)`,
/// the node sends a request to the URL cache.
open class URLNotModifiedTriggerNode: AsyncNode {

    // MARK: - Properties

    /// The next node for processing.
    public var next: any ResponseProcessingLayerNode

    /// Node for reading data from the cache.
    public var cacheReader: any AsyncNode<URLNetworkRequest, Json>

    // MARK: - Init and deinit

    /// Initializes the node.
    ///
    /// - Parameters:
    ///   - next: The next node for processing.
    ///   - cacheReader: Node for reading data from the cache.
    public init(next: some ResponseProcessingLayerNode,
                cacheReader: some AsyncNode<URLNetworkRequest, Json>) {
        self.next = next
        self.cacheReader = cacheReader
    }

    // MARK: - Node

    /// Checks the HTTP status code. If the code corresponds to NotModified, returns the request from the cache.
    /// Otherwise, passes control further.
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
