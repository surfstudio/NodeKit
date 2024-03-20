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

    func cancel(logContext: LoggingContextProtocol)
}

/// Узел, который позволяет отменить цепочку операций.
/// В качестве примера Aborter'а для запроса в сеть может выступать класс `RequestSenderNode`
///
/// - SeeAlso:
///     - `Aborter`
///     - `Node`
open class AborterNode<Input, Output>: Node {

    /// Следюущий в цепочке узел
    public var next: any Node<Input, Output>

    /// Сущность, отменяющая преобразование
    public var aborter: Aborter

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следюущий в цепочке узел
    ///   - aborter: Сущность, отменяющая преобразование
    public init(next: any Node<Input, Output>, aborter: Aborter) {
        self.next = next
        self.aborter = aborter
    }

    /// Просто передает поток следующему узлу
    /// и если пришло сообщение об отмене запроса, то посылает Aborter'у `cancel()`
    open func process(_ data: Input) -> Observer<Output> {
        return self.next.process(data)
            .multicast()
            .onCanceled { [weak self] in
                self?.aborter.cancel()
            }
    }

    /// Если в момент вызова process задача уже отменена, то вернет CancellationError
    /// Если process был вызван и получили событие отмены задачи, то посылает Aborter'у `cancel()`
    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> Result<Output, Error> {
        return await .withMappedExceptions {
            try Task.checkCancellation()
            return .success(())
        }
        .flatMap {
            return await withTaskCancellationHandler(
                operation: { return await next.process(data, logContext: logContext) },
                onCancel: { aborter.cancel(logContext: logContext) }
            )
        }
    }
}
