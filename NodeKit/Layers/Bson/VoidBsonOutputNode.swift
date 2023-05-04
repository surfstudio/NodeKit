//
//  VoidBsonOutputNode.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 01.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

open class VoidBsonOutputNode<Input>: Node<Input, Void> where Input: DTOEncodable, Input.DTO.Raw == Bson {

    let next: Node<Bson, Bson>

    init(next: Node<Bson, Bson>) {
        self.next = next
    }

    override open func process(_ data: Input) -> Observer<Void> {

        var newData: Bson

        do {
            newData = try data.toDTO().toRaw()
        } catch {
            return .emit(error: error)
        }

        return self.next.process(newData).map { [weak self] bson in
            let result = Context<Void>()
            guard let self = self else {
                return result.emit(data: ())
            }
            var log = Log(self.logViewObjectName, id: self.objectName, order: LogOrder.voidOutputNode)
            if !bson.isEmpty {
                log += "VoidOutputNode used but request have not empty response" + .lineTabDeilimeter
                log += "\(bson)"
                result.log(log)
            }
            return result.emit(data: ())
        }
    }
}
