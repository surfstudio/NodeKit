//
//  VoidIONode.swift
//  SBI
//
//  Created by Артемий Шабанов on 18/04/2019.
//  Copyright © 2019 Александр Кравченков. All rights reserved.
//

import Foundation

open class VoidIONode: AsyncNode {

    let next: any AsyncNode<Json, Json>

    init(next: some AsyncNode<Json, Json>) {
        self.next = next
    }

    open func process(
        _ data: Void,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Void> {
        await .withCheckedCancellation {
            await next.process(Json(), logContext: logContext).asyncFlatMap { json in
                if !json.isEmpty {
                    var log = LogChain("", id: objectName, logType: .info, order: LogOrder.voidIONode)
                    log += "VoidIOtNode used but request have not empty response"
                    log += .lineTabDeilimeter
                    log += "\(json)"
                    await logContext.add(log)
                }
                return .success(())
            }
        }
    }
}
