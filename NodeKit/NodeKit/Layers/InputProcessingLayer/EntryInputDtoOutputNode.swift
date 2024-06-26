//
//  EntryinputDtoOutputNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 15/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

open class EntryInputDtoOutputNode<Input, Output>: AsyncNode
                                                    where Input: RawEncodable, Output: DTODecodable {

    open var next: any AsyncNode<Input.Raw, Output.DTO.Raw>

    init(next: any AsyncNode<Input.Raw, Output.DTO.Raw>) {
        self.next = next
    }

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
        .asyncFlatMap { raw in
            await .withMappedExceptions {
                let dto = try Output.DTO.from(raw: raw)
                return .success(try Output.from(dto: dto))
            }
        }
    }
}
