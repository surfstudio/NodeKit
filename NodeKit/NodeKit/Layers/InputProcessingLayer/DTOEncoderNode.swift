//
//  DTOConverterNode.swift
//  NodeKit
//
//  Created by Александр Кравченков on 18/05/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// This node is capable of converting input data into DTOs, but does not attempt to decode the response.
open class DTOEncoderNode<Input, Output>: AsyncNode where Input: DTOEncodable {

    /// Node capable of working with DTOs.
    open var rawEncodable: any AsyncNode<Input.DTO, Output>

    /// Initializes the object.
    ///
    /// - Parameter rawEncodable: Node capable of working with DTOs.
    public init(rawEncodable: some AsyncNode<Input.DTO, Output>) {
        self.rawEncodable = rawEncodable
    }

    /// Tries to convert the model to a DTO, and then passes the conversion result to the next node.
    /// If an error occurs during conversion, it interrupts the execution of the chain.
    ///
    /// - Parameter data: Incoming model.
    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await .withMappedExceptions {
            .success(try data.toDTO())
        }
        .asyncFlatMap { dto in
            await .withCheckedCancellation {
                await rawEncodable.process(dto, logContext: logContext)
            }
        }
    }
}
