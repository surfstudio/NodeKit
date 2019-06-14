//
//  VoidIONode.swift
//  SBI
//
//  Created by Артемий Шабанов on 18/04/2019.
//  Copyright © 2019 Александр Кравченков. All rights reserved.
//

import Foundation

open class VoidIONode: Node<Void, Void> {

    let next: Node<Json, Json>

    init(next: Node<Json, Json>) {
        self.next = next
    }

    override open func process(_ data: Void) -> Observer<Void> {
        return self.next.process(Json()).map { json in
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
}
