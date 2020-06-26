//
//  VoidBsonIONode.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 03.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

open class VoidBsonIONode: Node<Void, Void> {

    let next: Node<Bson, Bson>

    init(next: Node<Bson, Bson>) {
        self.next = next
    }

    override open func process(_ data: Void) -> Observer<Void> {
        return self.next.process(Bson()).map { bson in
            let result = Context<Void>()
            var log = Log(self.logViewObjectName, id: self.objectName, order: LogOrder.voidIONode)
            if !bson.isEmpty {
                log += "VoidIOtNode used but request have not empty response" + .lineTabDeilimeter
                log += "\(bson)"
                result.log(log)
            }
            return result.emit(data: ())
        }
    }
}
