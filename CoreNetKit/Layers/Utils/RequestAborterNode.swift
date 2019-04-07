//
//  RequestAborterNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 03/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation


/// Протокол для сущности, которая может отменить операцию.
public protocol Aborter {
    /// Отменяет операцию.
    func cancel()
}

/// Узел, который позволяет отменить цепочку операций.
/// В качестве примера Aborter'а для запроса в сеть может выступать класс `RequestSenderNode`
///
/// - SeeAlso:
///     - `Aborter`
///     - `Node`
open class AborterNode<Input, Output>: Node<Input, Output> {

    /// Следюущий в цепочке узел
    public var next: Node<Input, Output>

    /// Сущность, отменяющая преобразование
    public var aborter: Aborter

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следюущий в цепочке узел
    ///   - aborter: Сущность, отменяющая преобразование
    public init(next: Node<Input, Output>, aborter: Aborter) {
        self.next = next
        self.aborter = aborter
    }

    /// Просто передает поток следующему узлу
    /// и если пришло сообщение об отмене запроса, то посылает Aborter'у `cancel()`
    open override func process(_ data: Input) -> Observer<Output> {
        return self.next.process(data)
            .multicast()
            .onCanceled {
                self.aborter.cancel()
            }
    }
}
