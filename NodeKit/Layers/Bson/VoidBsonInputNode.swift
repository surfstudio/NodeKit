//
//  VoidBsonInputNode.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 02.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

/// Узел, который позволяет передать на вход `Void`.
open class VoidBsonInputNode<Output>: Node<Void, Output> {

    /// Следующий узел для обработки.
    public var next: Node<Bson, Output>

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: Node<Bson, Output>) {
        self.next = next
    }

    /// Передает управление следующему узлу,в качестве параметра передает пустой `Json`
    open override func process(_ data: Void) -> Observer<Output> {
        return next.process(Bson())
    }
}
