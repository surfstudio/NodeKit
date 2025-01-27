//
//  VoidOutputNode.swift
//  SBI MOCK
//
//  Created by Александр Кравченков on 14/04/2019.
//  Copyright © 2019 Александр Кравченков. All rights reserved.
//

import Foundation

open class VoidOutputNode<Input>: AsyncNode where Input: DTOEncodable, Input.DTO.Raw == Json {

    let next: any AsyncNode<Json, Json>

    init(next: some AsyncNode<Json, Json>) {
        self.next = next
    }

    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Void> {
        await .withMappedExceptions {
            .success(try data.toDTO().toRaw())
        }
        .asyncFlatMap { raw in
            await .withCheckedCancellation {
                await next.process(raw, logContext: logContext).asyncFlatMap { json in
                    if !json.isEmpty {
                        var log = LogChain("", id: objectName, logType: .info, order: LogOrder.voidOutputNode)
                        log += "VoidOutputNode used but request have not empty response"
                        log += .lineTabDeilimeter
                        log += "\(json)"
                        await logContext.add(log)
                    }
                    return .success(())
                }
            }
        }
    }
}
