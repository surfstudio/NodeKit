//
//  DTOMapperNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

/// This node is responsible for mapping top-level DTO (``DTOConvertible``) to lower-level (``RawMappable``) and vice versa.
open class DTOMapperNode<Input, Output>: AsyncNode where Input: RawEncodable, Output: RawDecodable {

    /// The next node for processing.
    public var next: any AsyncNode<Input.Raw, Output.Raw>

    /// Initializes the node.
    ///
    /// - Parameter next: The next node for processing.
    public init(next: any AsyncNode<Input.Raw, Output.Raw>) {
        self.next = next
    }

    /// Maps data to ``RawMappable``, passes control to the next node, and then maps the response to ``DTOConvertible``.
    ///
    /// - Parameter data: The data for processing.
    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await .withMappedExceptions {
            return .success(try data.toRaw())
        }
        .asyncFlatMapError { error in
            await log(error: error, logContext: logContext)
            return .failure(error)
        }
        .asyncFlatMap { raw in
            await .withCheckedCancellation {
                await next.process(raw, logContext: logContext)
            }
        }
        .asyncFlatMap { result in
            await .withMappedExceptions {
                .success(try Output.from(raw: result))
            }
            .asyncFlatMapError { error in
                await log(error: error, logContext: logContext)
                return .failure(error)
            }
        }
    }

    private func log(error: Error, logContext: LoggingContextProtocol) async {
        let log = Log(
            logViewObjectName + "\(error)",
            id: objectName,
            order: LogOrder.dtoMapperNode
        )
        await logContext.add(log)
    }
}
