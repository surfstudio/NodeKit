//
//  AsyncNodeSubscription.swift
//  NodeKit
//
//  Created by Andrei Frolov on 17.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

/// Combine subscription for ``AsyncNode``.
/// Contains base implementation, inheriting from `BaseSubscription`.
/// - Warning: There is small delay between `subscriber.receive(_ input` and `subscriber.receive(completion:` to make sure that input will be published in publisher before completion.
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
            try? await Task.sleep(nanoseconds: 1_000_000)
            subscriber.receive(completion: .finished)
        }
    }
}
