//
//  CombineCompatibleNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 17.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation
import Combine

/// Protocol for a node describing the approach of transforming input data into a result using Combine.
public protocol CombineCompatibleNode<I, O> {
    associatedtype I
    associatedtype O
    
    /// Method for obtaining a Publisher to subscribe to the result.
    ///
    /// - Parameters:
    ///    - data: Input data for the node.
    ///    - scheduler: Scheduler for emitting the result.
    ///    - logContext: Log context.
    /// - Returns: Publisher to subscribe to the result.
    func nodeResultPublisher(
        for data: I,
        on scheduler: some Scheduler,
        logContext: LoggingContextProtocol
    ) -> AnyPublisher<NodeResult<O>, Never>
}

public extension CombineCompatibleNode {
    
    /// Method for obtaining a Publisher emitting the result on the main queue.
    ///
    /// - Parameters:
    ///    - data: Input data for the node.
    ///    - logContext: Log context.
    /// - Returns: Publisher to subscribe to the result.
    @discardableResult
    func nodeResultPublisher(
        for data: I,
        logContext: LoggingContextProtocol
    ) -> AnyPublisher<NodeResult<O>, Never> {
        return nodeResultPublisher(for: data, on: DispatchQueue.main, logContext: logContext)
    }
    
    /// Method for obtaining a Publisher with a new log context
    /// and a custom Scheduler for emitting the result.
    ///
    /// - Parameters:
    ///    - data: Input data for the node.
    ///    - scheduler: Scheduler for emitting the result.
    /// - Returns: Publisher to subscribe to the result.
    @discardableResult
    func nodeResultPublisher(
        for data: I,
        on scheduler: some Scheduler
    ) -> AnyPublisher<NodeResult<O>, Never> {
        return nodeResultPublisher(for: data, on: scheduler, logContext: LoggingContext())
    }
    
    /// Method for obtaining a Publisher with a new log context, emitting the result on the main queue.
    ///
    /// - Parameters:
    ///    - data: Input data for the node.
    /// - Returns: Publisher to subscribe to the result.
    @discardableResult
    func nodeResultPublisher(
        for data: I
    ) -> AnyPublisher<NodeResult<O>, Never> {
        return nodeResultPublisher(for: data, on: DispatchQueue.main)
    }
}

/// Contains syntactic sugar for working with nodes where the input type is `Void`.
public extension CombineCompatibleNode where I == Void {
    
    /// Method for obtaining a Publisher with a custom Scheduler.
    ///
    /// - Parameters:
    ///    - scheduler: Scheduler for emitting the result.
    ///    - logContext: Log context.
    /// - Returns: Publisher to subscribe to the result.
    func nodeResultPublisher(
        on scheduler: some Scheduler,
        logContext: LoggingContextProtocol
    ) -> AnyPublisher<NodeResult<O>, Never> {
        return nodeResultPublisher(for: Void(), on: scheduler, logContext: logContext)
    }
    
    /// Method for obtaining a Publisher with a custom Scheduler and creating a new log context.
    ///
    /// - Parameters:
    ///    - scheduler: Scheduler for emitting the result.
    /// - Returns: Publisher to subscribe to the result.
    @discardableResult
    func nodeResultPublisher(
        on scheduler: some Scheduler
    ) -> AnyPublisher<NodeResult<O>, Never> {
        return nodeResultPublisher(for: Void(), on: scheduler)
    }
    
    /// Method for obtaining a Publisher emitting the result on the main queue.
    ///
    /// - Parameters:
    ///    - logContext: Log context.
    /// - Returns: Publisher to subscribe to the result.
    func nodeResultPublisher(
        logContext: LoggingContextProtocol
    ) -> AnyPublisher<NodeResult<O>, Never> {
        return nodeResultPublisher(for: Void(), logContext: logContext)
    }
    
    /// Method for obtaining a Publisher with a new log context, emitting the result on the main queue.
    ///
    /// - Returns: Publisher to subscribe to the result.
    @discardableResult
    func nodeResultPublisher(
    ) -> AnyPublisher<NodeResult<O>, Never> {
        return nodeResultPublisher(for: Void())
    }
}
