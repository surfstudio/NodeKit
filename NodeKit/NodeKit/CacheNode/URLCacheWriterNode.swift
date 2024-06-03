//
//  URLCacheWriterNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// This node is responsible for writing data to the URL cache.
/// - Important: This is a "dumb" implementation where server-side policies and other considerations are not taken into account.
/// It is implied that this node does not participate in the chain but is a leaf of one of the nodes.
open class URLCacheWriterNode: AsyncNode {
    
    public init() { }

    /// Forms a `CachedURLResponse` with the policy `.allowed`, saves it to the cache,
    /// and then returns a message about the successful operation.
    open func process(
        _ data: URLProcessedResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Void> {
        await .withCheckedCancellation {
            let cached = CachedURLResponse(
                response: data.response,
                data: data.data,
                storagePolicy: .allowed
            )
            URLCache.shared.storeCachedResponse(cached, for: data.request)
            return .success(())
        }
    }
}
