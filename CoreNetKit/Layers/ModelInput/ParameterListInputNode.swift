//
//  ParameterListInputNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 23/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Этот узел позволяет инциаллизировать цепочку из JSON.
/// Это может быть полезно, если для цепочки необходимо несколько полей.
open class ParameterListInputNode<Output>: Node<Json, Output> where Output: DTOConvertible {

    /// Следующий узел для обработки.
    public var next: Node<Json, Output.DTO>

    /// Инициаллизирует объeкт.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: Node<Json, Output.DTO>) {
        self.next = next
    }

    /// Передает управление дальше, а посе получения ответа конвертирует `RawMappable` в `DTOConvertible`
    ///
    /// - Parameter data: Данные дл преобразований.
    open override func process(_ data: Json) -> Observer<Output> {
        return next.process(data).map { item in
            return try Output.toModel(from: item)
        }
    }
}
