//
//  VoidInputNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 23/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Узел, который позволяет передать на вход `Void`.
open class VoidInputNode<Output>: AsyncNode {

    /// Следующий узел для обработки.
    public var next: any AsyncNode<Json, Output>

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: any AsyncNode<Json, Output>) {
        self.next = next
    }

    /// Передает управление следующему узлу,в качестве параметра передает пустой `Json`
    open func process(
        _ data: Void,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        return await next.process(Json(), logContext: logContext)
    }
}
