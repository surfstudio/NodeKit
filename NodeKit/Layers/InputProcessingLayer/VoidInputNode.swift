//
//  VoidInputNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 23/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Узел, который позволяет передать на вход `Void`.
open class VoidInputNode<Output>: Node {

    /// Следующий узел для обработки.
    public var next: any Node<Json, Output>

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: any Node<Json, Output>) {
        self.next = next
    }

    /// Передает управление следующему узлу,в качестве параметра передает пустой `Json`
    open func process(_ data: Void) -> Observer<Output> {
        return next.process(Json())
    }

    /// Передает управление следующему узлу,в качестве параметра передает пустой `Json`
    open func process(
        _ data: Void,
        logContext: LoggingContextProtocol
    ) async -> Result<Output, Error> {
        return await next.process(Json(), logContext: logContext)
    }
}

// MARK: - Node void extension

/// Содержит иснтаксический сахар для работы с узлами, у которых входящий тип = `Void`
extension Node where Input == Void {
    /// Вызывает `process(_:)`
    func process() -> Observer<Output> {
        return self.process(Void())
    }
}
