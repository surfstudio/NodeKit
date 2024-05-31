//
//  RawEncoderNode.swift
//  NodeKit
//
//  Created by Александр Кравченков on 18/05/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// This node can convert input data to Raw, but does not attempt to decode the response.
open class RawEncoderNode<Input, Output>: AsyncNode where Input: RawEncodable {

    /// The next node for processing.
    open var next: any AsyncNode<Input.Raw, Output>

    /// Initializer.
    ///
    /// - Parameter next: The next node for processing.
    public init(next: some AsyncNode<Input.Raw, Output>) {
        self.next = next
    }

    /// Tries to convert the model to Raw and then simply passes the conversion result to the next node.
    /// If an error occurs during conversion, it aborts the chain execution.
    ///
    /// - Parameter data: The incoming model.
    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await .withMappedExceptions {
            .success(try data.toRaw())
        }
        .asyncFlatMap { raw in
            await .withCheckedCancellation {
                await next.process(raw, logContext: logContext)
            }
        }
    }
}
