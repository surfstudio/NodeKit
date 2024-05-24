//
//  AsyncNodeResultPublisher.swift
//  NodeKit
//
//  Created by Andrei Frolov on 17.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine

/// Publisher для ``AsyncNode``
struct AsyncNodeResultPublisher<Node: AsyncNode>: NodeResultPublisher {
    
    // MARK: Nested Types
    
    typealias Output = NodeResult<Node.Output>
    typealias Failure = Never
    
    // MARK: - NodeResultPublisher
    
    let node: Node
    let input: Node.Input
    let logContext: LoggingContextProtocol
    
    // MARK: - Initialization
    
    init(node: Node, input: Node.Input, logContext: LoggingContextProtocol) {
        self.node = node
        self.input = input
        self.logContext = logContext
    }
    
    // MARK: - Publisher
    
    /// Метод создания подписки для подписчика.
    func receive<S: NodeSubscriber<Node>>(subscriber: S) {
        let subscription = AsyncNodeSubscription<Node, S>(parent: self, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}
