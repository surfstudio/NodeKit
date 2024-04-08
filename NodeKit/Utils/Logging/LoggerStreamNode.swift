//
//  LoggerStreamNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

/// Этот узел выполняет выведение лога в консоль.
/// Сразу же передает управление следующему узлу и подписывается на выполнение операций.
open class LoggerStreamNode<Input, Output>: AsyncStreamNode {
    
    /// Следующий узел для обработки.
    open var next: any AsyncStreamNode<Input, Output>
    /// Содержит список ключей, по которым будет отфлитрован лог.
    open var filters: [String]

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обработки.
    ///   - filters: Содержит список ключей, по которым будет отфлитрован лог.
    public init(next: any AsyncStreamNode<Input, Output>, filters: [String] = []) {
        self.next = next
        self.filters = filters
    }

    /// Сразу же передает управление следующему узлу и подписывается на выполнение операций.
    ///
    /// - Parameter data: Данные для обработки. Этот узел их не импользует.
    public func process(_ data: Input, logContext: LoggingContextProtocol) -> AsyncStream<NodeResult<Output>> {
        return AsyncStream { continuation in
            Task {
                for await result in next.process(data, logContext: logContext) {
                    continuation.yield(result)
                }
                await logContext.log?.flatMap()
                    .filter { !filters.contains($0.id) }
                    .sorted(by: { $0.order < $1.order })
                    .forEach { print($0.description) }
                continuation.finish()
            }
        }
    }
}
