//
//  MergedAsyncStreamNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 06.05.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

/// Этот узел реализует объединение двух узлов в один узел, поддерживающий работу с потоком данных.
/// Первым вызывает process у первого переданного узла, затем у второго.
/// В общем случае слушатель может быть оповещен дважды.
open class MergedAsyncStreamNode<Input, Output>: AsyncStreamNode {

    // MARK: - Properties

    /// Первый узел обработки данных.
    public var firstNode: any AsyncNode<Input, Output>

    /// Второй узел обработки данных.
    public var secondNode: any AsyncNode<Input, Output>

    // MARK: - Initialization
    
    public init(
        firstNode: any AsyncNode<Input, Output>,
        secondNode: any AsyncNode<Input, Output>
    ) {
        self.firstNode = firstNode
        self.secondNode = secondNode
    }

    // MARK: - AsyncStreamNode
    
    /// Вызывает process у первой ноды, возвращает результат.
    /// Затем вызывает process у второй ноды, возвращает результат и заканчивает работу.
    public func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) -> AsyncStream<NodeResult<Output>> {
        return AsyncStream { continuation in
            Task {
                let firstResult = await firstNode.process(data, logContext: logContext)
                continuation.yield(firstResult)
                
                let secondResult = await secondNode.process(data, logContext: logContext)
                continuation.yield(secondResult)
                continuation.finish()
            }
        }
    }
}
