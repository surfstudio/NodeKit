//
//  EntryinputDtoOutputNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 15/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

open class EntryinputDtoOutputNode<Input, Output>: Node<Input, Output>
                                                    where Input: RawEncodable, Output: DTODecodable {

    open var next: Node<Input.Raw, Output.DTO.Raw>

    init(next: Node<Input.Raw, Output.DTO.Raw>) {
        self.next = next
    }

    open override func process(_ data: Input) -> Observer<Output> {
        do {
            let raw = try data.toRaw()
            return self.next.process(raw).map { try Output.from(dto: Output.DTO.from(raw: $0) ) }
        } catch {
            return .emit(error: error)
        }
    }

}
