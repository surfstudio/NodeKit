//
//  AsyncStreamNodeSubscription.swift
//  NodeKit
//
//  Created by Andrei Frolov on 17.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

/// Combine подписка для ``AsyncStreamNode``.
/// Содержит базовую релазацию, наследуя BaseSubscription.
final class AsyncStreamNodeSubscription<Node: AsyncStreamNode, S: NodeSubscriber<Node>>:
    BaseSubscription<AsyncStreamNodeResultPublisher<Node>, S> {
    
    // MARK: - BaseSubscription
    
    /// Метод создания таски для выполенения обработки данных.
    ///
    /// - Parameters:
    ///    - node: Нода, которая будет отвечать за обработку данных.
    ///    - input: Входные данные ноды
    ///    - logContext: Контекст логов.
    ///    - subscriber: Подписчик, который будет получать результат ноды.
    /// - Returns: SwiftConcurrency Task.
    override func synchronizedRunTask(
        node: Node,
        input: Node.Input,
        logContext: LoggingContextProtocol,
        subscriber: S
    ) -> Task<(), Never> {
        return Task {
            for await result in node.process(input, logContext: logContext) {
                _ = subscriber.receive(result)
            }
            subscriber.receive(completion: .finished)
        }
    }
}

