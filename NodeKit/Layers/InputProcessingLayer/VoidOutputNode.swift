//
//  VoidOutputNode.swift
//  SBI MOCK
//
//  Created by Александр Кравченков on 14/04/2019.
//  Copyright © 2019 Александр Кравченков. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
open class VoidOutputNode<Input>: Node<Input, Void> where Input: DTOEncodable, Input.DTO.Raw == Json {

    let next: Node<Json, Json>

    init(next: Node<Json, Json>) {
        self.next = next
    }

    override open func process(_ data: Input) async -> Result<Void, Error> {
        return await .withMappedExceptions {
            let newData = try data.toDTO().toRaw()
            return await next.process(newData).flatMap { _ in .success(()) }
        }
    }
}
