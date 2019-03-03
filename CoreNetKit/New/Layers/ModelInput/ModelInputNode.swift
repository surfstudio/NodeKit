//
//  ModelInputNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

public enum BaseCommonError: Error {
    case nextNodeIsNil
}

public class ModelInputNode<Input, Output>: Node<Input, Output> where Input: DTOConvertible, Output: DTOConvertible {

    public var next: Node<Input.DTO, Output.DTO>

    public init(next: Node<Input.DTO, Output.DTO>) {
        self.next = next
    }

    open override func process(_ data: Input) -> Observer<Output> {

        let context = Context<Output>()

        do {
            let data = try data.toDTO()
            return next.process(data)
                .map { try Output.toModel(from: $0) }
        } catch {
            return context.emit(error: error)
        }
    }
}

public class SimpleModelInputNode<Input, Output>: Node<Input, Output> where Input: RawMappable, Output: DTOConvertible {

    public var next: Node<Input, Output.DTO>

    public init(next: Node<Input, Output.DTO>) {
        self.next = next
    }

    open override func process(_ data: Input) -> Observer<Output> {

        return self.next.process(data).map {
            try Output.toModel(from: $0)
        }
    }
}
