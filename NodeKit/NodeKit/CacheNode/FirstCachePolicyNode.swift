//
//  CachePreprocessor.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Errors for the node `FirstCachePolicyNode`
///
/// - SeeAlso: `FirstCachePolicyNode`
///
/// - cantGetURLRequest: Occurs if the request sent over the network does not contain a `URLRequest`
enum BaseFirstCachePolicyNodeError: Error {
    case cantGetURLRequest
}

/// This node implements the caching policy
/// "First, read from the cache, then request from the server"
/// - Important: In general, the listener may be notified twice. The first time when the response is read from the cache, and the second time when it is received from the server.
class FirstCachePolicyNode: AsyncStreamNode {
    // MARK: - Nested

    /// Type of the node reading from URL cache
    typealias CacheReaderNode = AsyncNode<URLNetworkRequest, Json>

    /// Type of the next node
    typealias NextProcessorNode = AsyncNode<RawURLRequest, Json>

    // MARK: - Properties

    /// The next node for processing.
    var next: any NextProcessorNode

    /// Node for reading from cache.
    var cacheReaderNode: any CacheReaderNode

    // MARK: - Init and Deinit

    /// Initializer.
    ///
    /// - Parameters:
    ///   - cacheReaderNode: Node for reading from cache.
    ///   - next: Next node for processing.
    init(cacheReaderNode: any CacheReaderNode, next: any NextProcessorNode) {
        self.cacheReaderNode = cacheReaderNode
        self.next = next
    }

    // MARK: - Node
    
    /// Tries to get the `URLRequest` and if successful, accesses the cache
    /// and then passes control to the next node.
    /// If obtaining the `URLRequest` fails,
    /// control is passed to the next node.
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
