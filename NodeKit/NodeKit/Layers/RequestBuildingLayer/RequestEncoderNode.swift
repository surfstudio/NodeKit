//
//  RequestEncoderNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// This node adds encoding to the request being created.
open class RequestEncoderNode<Raw, Route, Encoding, Output>: AsyncNode {

    /// Type for the next node.
    public typealias NextNode = AsyncNode<EncodableRequestModel<Route, Raw, Encoding>, Output>

    /// The next node for processing.
    public var next: any NextNode

    /// Encoding for the request.
    public var encoding: Encoding

    /// Initializes the node.
    ///
    /// - Parameters:
    ///   - next: The next node for processing.
    ///   - encoding: Encoding for the request.
    public init(next: some NextNode, encoding: Encoding) {
        self.next = next
        self.encoding = encoding
    }

    /// Converts ``RoutableRequestModel`` into ``EncodableRequestModel``
    /// and passes control to the next node.
    open func process(
        _ data: RoutableRequestModel<Route, Raw>,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await .withCheckedCancellation {
            let model = EncodableRequestModel(
                metadata: data.metadata,
                raw: data.raw,
                route: data.route,
                encoding: encoding
            )
            return await next.process(model, logContext: logContext)
        }
    }
}
