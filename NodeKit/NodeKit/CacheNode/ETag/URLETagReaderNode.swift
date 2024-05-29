//
//  EtagReaderNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// This node reads the eTag token from the storage and adds it to the request.
open class URLETagReaderNode: AsyncNode {

    // The next node for processing.
    public var next: any TransportLayerNode

    /// The key to retrieve the eTag token from the headers.
    /// By default, it has the value `eTagRequestHeaderKey`.
    public var etagHeaderKey: String

    /// Initializes the node.
    ///
    /// - Parameters:
    ///   - next: The next node for processing.
    ///   - eTagHeaderKey: The key to add the eTag token to the request.
    public init(next: some TransportLayerNode,
                etagHeaderKey: String = ETagConstants.eTagRequestHeaderKey) {
        self.next = next
        self.etagHeaderKey = etagHeaderKey
    }

    /// Tries to read the eTag token from the storage and add it to the request.
    /// If reading the token fails, control is simply passed on.
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
