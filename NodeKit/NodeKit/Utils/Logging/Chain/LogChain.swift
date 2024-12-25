//
//  LogChain.swift
//
//  Created by Александр Кравченков on 07/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Structure describing the work log.
public struct LogChain: LogableChain {

    /// The order of the log in the chain. Necessary for sorting.
    public var order: Double = 0

    /// Separator to be inserted between logs.
    /// By default, it is equal to `\n`.
    public var delimeter: String

    /// Next log.
    public var next: LogableChain?

    /// The content of this log.
    public var message: String

    /// Log identifier.
    public var id: String

    public var logType: LogType

    /// Initializes the object.
    ///
    /// - Parameters:
    ///   - message: The content of this log.
    ///   - id: Log identificator.
    ///   - logType: Type of the log.
    ///   - delimeter: Separator to be inserted between logs. By default, it is equal to `\n`.
    ///   - order: Log order.
    public init(
        _ message: String,
        id: String,
        logType: LogType,
        delimeter: String = "\n",
        order: Double = 0
    ) {
        self.message = message
        self.delimeter = delimeter
        self.id = id
        self.logType = logType
        self.order = order
    }

    /// Appends `delimeter` to its own `message`, then appends `next.description` to the resulting string.
    public var description: String {
        let result = self.delimeter + message + self.delimeter
        return result + (self.next?.description ?? "")
    }

    /// Formatted description with id.
    public var printString: String {
        let id = "<<<===\(self.id)===>>>" + .lineTabDeilimeter
        return id + description
    }

    /// Adds a message to the log.
    ///
    /// - Parameter message: Log message.
    mutating public func add(message: String) {
        self.message += message
    }

    /// Updates log type.
    ///
    /// - Parameter logType: Type of the log.
    mutating public func update(logType: LogType) {
        self.logType = logType
    }

    /// Syntactic sugar for add(message:)
    public static func += (lhs: inout LogChain, rhs: String) {
        lhs.add(message: rhs)
    }
}
