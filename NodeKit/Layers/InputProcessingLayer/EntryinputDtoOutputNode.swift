//
//  EntryinputDtoOutputNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 15/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
open class EntryinputDtoOutputNode<Input, Output>: Node<Input, Output>
                                                    where Input: RawEncodable, Output: DTODecodable {

    open var next: Node<Input.Raw, Output.DTO.Raw>

    init(next: Node<Input.Raw, Output.DTO.Raw>) {
        self.next = next
    }

    open override func process(_ data: Input) async -> Result<Output, Error> {
        return await .withMappedExceptions {
            let raw = try data.toRaw()
            return try await next.process(raw).map {
                let dto = try Output.DTO.from(raw: $0)
                return try Output.from(dto: dto)
            }
        }
    }

}
