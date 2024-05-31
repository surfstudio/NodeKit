//
//  AsyncStreamNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine
import Foundation

/// Protocol for a node describing the approach of transforming input data into a result using Swift Concurrency.
/// Supports result processing with Combine by inheriting the ``CombineCompatibleNode`` protocol.
/// Contains parameters for logging, inheriting the ``Node`` protocol.
/// Applicable for nodes that can return multiple results.
protocol AsyncStreamNode<Input, Output>: Node, CombineCompatibleNode<Self.Input, Self.Output> {
    associatedtype Input
    associatedtype Output

    /// Asynchronous method containing logic for data processing.
    ///
    /// - Parameter data: Input data.
    /// - Returns: Stream of data processing results.
    @discardableResult
    func process(_ data: Input, logContext: LoggingContextProtocol) -> AsyncStream<NodeResult<Output>>
    
    /// Method returning the wrapper structure of the current node.
    /// Necessary to avoid problems arising from the use of  any AsyncStreamNode.
    ///
    /// - Returns: Wrapper structure of the current node `AnyAsyncStreamNode`.
    func eraseToAnyNode() -> AnyAsyncStreamNode<Input, Output>
}

extension AsyncStreamNode {
    
    /// Method `process` with the creation of a new log context.
    @discardableResult
    func process(_ data: Input) -> AsyncStream<NodeResult<Output>> {
        return process(data, logContext: LoggingContext())
    }

    /// Method for obtaining a Publisher to subscribe to the result.
    /// Base implementation of ``CombineCompatibleNode``.
    /// Calls the `process` method with a new task upon each subscription.
    /// Calls `cancel` on the task when `cancel` is invoked in `AnyCancellable` object.
    ///
    /// - Parameters:
    ///    - data: Input data for the node.
    ///    - scheduler: Scheduler for emitting the result.
    ///    - logContext: Log context.
    /// - Returns: Publisher to subscribe to the result.
    @discardableResult
    func nodeResultPublisher(
        for data: Input,
        on scheduler: some Scheduler,
        logContext: LoggingContextProtocol
    ) -> AnyPublisher<NodeResult<Output>, Never> {
        return AsyncStreamNodeResultPublisher(node: self, input: data, logContext: logContext)
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    /// Method returning the wrapper structure of the current node.
    /// Necessary to avoid problems arising from the use of any AsyncStreamNode.
    ///
    /// - Returns: Wrapper structure of the current node ``AnyAsyncStreamNode``.
    func eraseToAnyNode() -> AnyAsyncStreamNode<Input, Output> {
        return AnyAsyncStreamNode(node: self)
    }
}

/// Contains syntactic sugar for working with nodes where the input type is `Void`.
extension AsyncStreamNode where Input == Void {
    
    /// Calls `process(Void())`.
    @discardableResult
    func process() -> AsyncStream<NodeResult<Output>> {
        return process(Void())
    }
}
