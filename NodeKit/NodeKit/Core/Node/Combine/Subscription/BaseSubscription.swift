//
//  BaseSubscription.swift
//  NodeKit
//
//  Created by Andrei Frolov on 17.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation
import Combine

/// Abstract implementation of subscription for ``CombineCompatibleNode``.
/// Upon requesting data, creates a new task and saves it.
/// Upon cancellation of the subscription, calls cancel on the task.
class BaseSubscription<Parent: NodeResultPublisher, S: NodeSubscriber<Parent.Node>>: Subscription {
    
    // MARK: - Private Properties
    
    private let lock = NSLock()
    
    private var task: Task<(), Never>?
    private var demand = Subscribers.Demand.none
    private var parent: Parent?
    private var subscriber: S?
    
    // MARK: - Initialization
    
    init(parent: Parent, subscriber: S) {
        self.parent = parent
        self.subscriber = subscriber
    }
    
    // MARK: - Subscription
    
    func request(_ demand: Subscribers.Demand) {
        synchronized {
            guard
                demand != .zero,
                task == nil,
                let parent = parent,
                let subscriber = subscriber
            else {
                return
            }
            
            task = synchronizedRunTask(
                node: parent.node,
                input: parent.input,
                logContext: parent.logContext,
                subscriber: subscriber
            )
            self.demand += demand
        }
    }
    
    func cancel() {
        synchronized {
            task?.cancel()
            parent = nil
            subscriber = nil
            demand = .none
            task = nil
        }
    }
    
    // MARK: - Methods
    
    /// Method for creating a task to perform data processing.
    ///
    /// - Parameters:
    ///    - node: The node responsible for processing the data.
    ///    - input: Input data for the node.
    ///    - logContext: Log context.
    ///    - subscriber: Subscriber that will receive the node's result.
    /// - Returns: Swift Concurrency Task.
    func synchronizedRunTask(
        node: Parent.Node,
        input: Parent.Node.I,
        logContext: LoggingContextProtocol,
        subscriber: S
    ) -> Task<(), Never> {
        fatalError("Override method in subclass")
    }
}

// MARK: - Private Methods

private extension BaseSubscription {
    
    func synchronized(_ function: () -> Void) {
        lock.lock()
        function()
        lock.unlock()
    }
}
