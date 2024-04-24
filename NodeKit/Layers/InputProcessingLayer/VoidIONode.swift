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

    open func processLegacy(_ data: Void) -> Observer<Void> {
        return self.next.processLegacy(Json()).map { json in
            let result = Context<Void>()
            var log = Log(self.logViewObjectName, id: self.objectName, order: LogOrder.voidIONode)
            if !json.isEmpty {
                log += "VoidIOtNode used but request have not empty response" + .lineTabDeilimeter
                log += "\(json)"
                result.log(log)
            }
            return result.emit(data: ())
        }
    }

    open func process(
        _ data: Void,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Void> {
        return await next.process(Json(), logContext: logContext).asyncFlatMap { json in
            if !json.isEmpty {
                var log = Log(logViewObjectName, id: objectName, order: LogOrder.voidIONode)
                log += "VoidIOtNode used but request have not empty response"
                log += .lineTabDeilimeter
                log += "\(json)"
                await logContext.add(log)
            }
            return .success(())
        }
    }
}
