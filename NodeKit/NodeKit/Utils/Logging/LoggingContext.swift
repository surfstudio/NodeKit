//
//  LoggingContext.swift
//  NodeKit
//
//  Created by frolov on 19.03.2024.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

public protocol LoggingContextProtocol: LogSession {
    /// Root log.
    var log: LogableChain? { get }

    /// Adds a log message to the context.
    /// - Parameter log: Log message.
    func add(_ log: LogableChain?)

    /// Sets method and route to the log context.
    /// - Parameters:
    ///   - method: Request method.
    ///   - route: URL route.
    func set(method: Method?, route: URLRouteProvider?)

    /// Notify subscriptions about completion.
    func complete()
}

public actor LoggingContext: LoggingContextProtocol {

    /// Request Method
    public private(set) var method: Method?

    /// Request Route
    public private(set) var route: URLRouteProvider?

    /// Root log.
    public private(set) var log: LogableChain?

    /// Log subscriptions.
    private var logSubscriptions: [([Log]) -> Void] = []
    private var isCompleted = false

    private var logs: [Log]? {
        return log?.flatMap().sorted(by: { $0.order < $1.order })
    }

    /// Adds a log message to the context.
    /// If the context did not have a root log, the passed log will become the root.
    /// If the context had a root log but it did not have a next one, then the passed log will be added as the next log.
    /// If there was a root log and it had a next log, then the passed log will be inserted between them.
    ///
    /// - Parameter log: Log message.
    public func add(_ log: LogableChain?) {
        guard var currentLog = self.log else {
            self.log = log
            return
        }

        if currentLog.next == nil {
            currentLog.next = log
        } else {
            var temp = log
            temp?.next = currentLog.next
            currentLog.next = temp
        }

        self.log = currentLog
    }

    /// Sets method and route to the log context.
    /// - Parameters:
    ///   - method: Request method.
    ///   - route: URL route.
    public func set(method: Method?, route: URLRouteProvider?) {
        self.method = method
        self.route = route
    }

    /// Add subscriptions for logs.
    public func subscribe(_ subscription: @escaping ([Log]) -> Void) {
        guard isCompleted else {
            logSubscriptions.append(subscription)
            return
        }
        notify(subscription: subscription)
    }

    /// Notify subscriptions about completion.
    public func complete() {
        isCompleted = true
        notifySubscriptions()
    }

}

// MARK: - Private Methods

private extension LoggingContext {

    func notifySubscriptions() {
        guard let logs = logs, !logs.isEmpty else {
            return
        }
        logSubscriptions.forEach { subscription in
            subscription(logs)
        }
    }

    func notify(subscription: @escaping ([Log]) -> Void) {
        guard let logs = logs, !logs.isEmpty else {
            return
        }
        subscription(logs)
    }

}
