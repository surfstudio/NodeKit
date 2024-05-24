//
//  AsyncNodeSubscription.swift
//  NodeKit
//
//  Created by Andrei Frolov on 17.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

/// Combine подписка для ``AsyncNode``.
/// Содержит базовую релазацию, наследуя BaseSubscription.
final class AsyncNodeSubscription<Node: AsyncNode, S: NodeSubscriber<Node>>:
    BaseSubscription<AsyncNodeResultPublisher<Node>, S> {
    
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
            let result = await node.process(input, logContext: logContext)
            _ = subscriber.receive(result)
            subscriber.receive(completion: .finished)
        }
    }
}
