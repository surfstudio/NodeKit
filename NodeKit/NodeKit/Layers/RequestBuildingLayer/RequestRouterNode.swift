//
//  RequestRouterNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// This node adds a route to the request.
open class RequestRouterNode<Raw, Route, Output>: AsyncNode {

    /// Type for the next node.
    public typealias NextNode = AsyncNode<RoutableRequestModel<Route, Raw>, Output>

    /// The next node for processing.
    public var next: any NextNode

    /// Route for the request.
    public var route: Route

    /// Initializes the node
    ///
    /// - Parameters:
    ///   - next: The next node for processing.
    ///   - route: The route for the request.
    public init(next: any NextNode, route: Route) {
        self.next = next
        self.route = route
    }

    /// Converts ``RequestModel`` to ``RoutableRequestModel`` and passes control to the next node
    open func process(
        _ data: RequestModel<Raw>,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await .withCheckedCancellation {
            await next.process(
                RoutableRequestModel(metadata: data.metadata, raw: data.raw, route: route),
                logContext: logContext
            )
        }
    }
}
