//
//  RequestAborterNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 03/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation


/// Protocol for an entity that can cancel an operation.
public protocol Aborter {

    /// Cancels an asynchronous operation.
    func cancel(logContext: LoggingContextProtocol)
}

/// Node that allows aborting a chain of operations.
/// For example, a RequestSenderNode class can act as an aborter for network requests.
open class AborterNode<Input, Output>: AsyncNode {

    /// The next node for processing.
    public var next: any AsyncNode<Input, Output>

    /// Entity canceling transformation.
    public var aborter: Aborter

    /// Initializes the node.
    ///
    /// - Parameters:
    ///   - next: The next node in the chain.
    ///   - aborter: Entity canceling transformation.
    public init(next: any AsyncNode<Input, Output>, aborter: Aborter) {
        self.next = next
        self.aborter = aborter
    }

    /// If the task is already canceled at the time of calling process, it returns CancellationError.
    /// If process was called and a task cancellation event is received, it sends `cancel()` to the Aborter.
    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await withTaskCancellationHandler(
            operation: {
                await .withCheckedCancellation {
                    await next.process(data, logContext: logContext)
                }
            },
            onCancel: { aborter.cancel(logContext: logContext) }
        )
    }
}
