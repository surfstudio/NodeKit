//
//  VoidOutputNode.swift
//  SBI MOCK
//
//  Created by Александр Кравченков on 14/04/2019.
//  Copyright © 2019 Александр Кравченков. All rights reserved.
//

import Foundation

open class VoidOutputNode<Input>: Node<Input, Void> where Input: DTOEncodable, Input.DTO.Raw == Json {

    let next: Node<Json, Json>

    init(next: Node<Json, Json>) {
        self.next = next
    }

    override open func process(_ data: Input) -> Observer<Void> {

        var newData: Json

        do {
            newData = try data.toDTO().toRaw()
        } catch {
            return .emit(error: error)
        }

        return self.next.process(newData).map { json in
            let result = Context<Void>()
            var log = Log(self.logViewObjectName, id: self.objectName, order: LogOrder.voidOutputNode)
            if !json.isEmpty {
                log += "VoidOutputNode used but request have not empty response" + .lineTabDeilimeter
                log += "\(json)"
                result.log(log)
            }
            return result.emit(data: ())
        }
    }
}
