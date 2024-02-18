//
//  DTOMapperNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

/// Этот узел отвечает за маппинг верхнего уровня DTO (`DTOConvertible`) в нижний уровень (`RawMappable`) и наборот.
@available(iOS 13.0, *)
open class DTOMapperNode<Input, Output>: Node<Input, Output> where Input: RawEncodable, Output: RawDecodable {

    /// Следующий узел для обрабтки.
    public var next: Node<Input.Raw, Output.Raw>

    /// Инциаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обрабтки.
    public init(next: Node<Input.Raw, Output.Raw>) {
        self.next = next
    }

    /// Маппит данные в RawMappable, передает управление следующей цепочке, а затем маппит ответ в DTOConvertible
    ///
    /// - Parameter data: Данные для обработки.
    open override func process(_ data: Input) async -> Result<Output, Error> {
        return await .withMappedExceptions {
            let data = try data.toRaw()
            let nextProcessResult = await next.process(data)
            return try nextProcessResult.map { result in
                return try Output.from(raw: result)
            }
        }
    }
}
