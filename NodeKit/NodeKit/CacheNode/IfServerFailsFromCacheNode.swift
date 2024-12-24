//
//  IfServerFailsFromCacheNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Node implements the caching policy "If there is no internet, request data from cache"
/// This node works with the URL cache.
open class IfConnectionFailedFromCacheNode: AsyncNode {

    /// The next node for processing.
    public var next: any AsyncNode<URLRequest, Json>
    /// Node that reads data from the URL cache.
    public var cacheReaderNode: any AsyncNode<URLNetworkRequest, Json>

    /// Initializer.
    ///
    /// - Parameters:
    ///   - next: The next node for processing.
    ///   - cacheReaderNode: Node that reads data from the URL cache.
    public init(next: any AsyncNode<URLRequest, Json>, cacheReaderNode: any AsyncNode<URLNetworkRequest, Json>) {
        self.next = next
        self.cacheReaderNode = cacheReaderNode
    }

    /// Checks if there was a ``BaseTechnicalError``  in response to the request.
    /// If an error occurred, returns a successful response from the cache.
    /// Otherwise, passes control to the next node.
    open func process(
        _ data: URLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Json> {
        await .withCheckedCancellation {
            await next.process(data, logContext: logContext)
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
    }

    // MARK: - Private Method

    private func makeBaseTechinalLog(with error: Error) -> LogChain {
        return LogChain(
                "Catching \(error)" + .lineTabDeilimeter +
                "Start read cache" + .lineTabDeilimeter,
            id: objectName, 
            logType: .failure
        )
    }

    private func makeLog(with error: Error, from request: URLNetworkRequest) -> LogChain {
        return LogChain(
                "Catching \(error)" + .lineTabDeilimeter +
                "Error is \(type(of: error))" +
                "and request = \(String(describing: request))" + .lineTabDeilimeter +
                "-> throw error",
            id: objectName,
            logType: .failure
        )
    }

}
