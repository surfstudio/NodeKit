//
//  AsyncNodeSubscription.swift
//  NodeKit
//
//  Created by Andrei Frolov on 17.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

/// Combine subscription for ``AsyncNode``.
/// Contains base implementation, inheriting from `BaseSubscription`.
final class AsyncNodeSubscription<Node: AsyncNode, S: NodeSubscriber<Node>>:
    BaseSubscription<AsyncNodeResultPublisher<Node>, S> {
    
    // MARK: - BaseSubscription
    
    /// Method for creating a task to perform data processing.
    ///
    /// - Parameters:
    ///    - node: The node responsible for processing the data.
    ///    - input: Input data for the node.
    ///    - logContext: Log context.
    ///    - subscriber: Subscriber that will receive the node's result.
    /// - Returns: Swift Concurrency Task.
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
