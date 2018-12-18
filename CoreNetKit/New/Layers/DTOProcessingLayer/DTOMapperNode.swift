//
//  DTOMapperNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

open class DTOMapperNode<Input, Output>: Node<Input, Output> where Input: RawMappable, Output: RawMappable {

    public var next: Node<Input.Raw, Output.Raw>

    public init(next: Node<Input.Raw, Output.Raw>) {
        self.next = next
    }

    open override func process(_ data: Input) -> Context<Output> {
        let context = Context<Output>()

        do {
            let data = try data.toRaw()
            return next.process(data)
                .map { try Output.toModel(from: $0) }
        } catch {
            return context.emit(error: error)
        }
    }
}
