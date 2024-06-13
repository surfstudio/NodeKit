//
//  LoggingContext.swift
//  NodeKit
//
//  Created by frolov on 19.03.2024.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

public protocol LoggingContextProtocol: Actor {
    /// Root log.
    var log: Logable? { get }

    /// Adds a log message to the context.
    /// - Parameter log: Log message.
    func add(_ log: Logable?)
}

public actor LoggingContext: LoggingContextProtocol {

    /// Root log.
    public private(set) var log: Logable?

    /// Adds a log message to the context.
    /// If the context did not have a root log, the passed log will become the root.
    /// If the context had a root log but it did not have a next one, then the passed log will be added as the next log.
    /// If there was a root log and it had a next log, then the passed log will be inserted between them.
    ///
    /// - Parameter log: Log message.
    public func add(_ log: Logable?) {
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
        return
    }

}
