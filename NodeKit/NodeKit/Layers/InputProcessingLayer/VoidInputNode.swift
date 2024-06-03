//
//  VoidInputNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 23/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Node that allows passing `Void` as input.
open class VoidInputNode<Output>: AsyncNode {

    /// The next node for processing.
    public var next: any AsyncNode<Json, Output>

    /// Initializer.
    ///
    /// - Parameter next: The next node for processing.
    public init(next: any AsyncNode<Json, Output>) {
        self.next = next
    }

    /// Passes control to the next node, passing an empty `Json` as a parameter.
    open func process(
        _ data: Void,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await .withCheckedCancellation {
            await next.process(Json(), logContext: logContext)
        }
    }
}
