//
//  ModelInputNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

/// Node for initializing data processing.
/// Used for working with models represented by two layers of DTOs.
public class ModelInputNode<Input, Output>: AsyncNode where Input: DTOEncodable, Output: DTODecodable {

    /// The next node for processing.
    public var next: any AsyncNode<Input.DTO, Output.DTO>

    /// Initializer.
    ///
    /// - Parameter next: The next node for processing.
    public init(next: any AsyncNode<Input.DTO, Output.DTO>) {
        self.next = next
    }

    /// Passes control to the next node,
    /// and upon receiving a response, attempts to map the lower DTO layer to the higher one.
    ///
    /// - Parameter data: Data for the request.
    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await .withMappedExceptions {
            .success(try data.toDTO())
        }
        .asyncFlatMap { dto in
            await .withCheckedCancellation {
                await next.process(dto, logContext: logContext)
            }
        }
        .asyncFlatMap { dto in
            await .withMappedExceptions {
                .success(try Output.from(dto: dto))
            }
        }
    }
}
