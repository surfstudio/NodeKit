//
//  Log.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 07/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Structure describing the work log.
public struct Log: Logable {

    /// The order of the log in the chain. Necessary for sorting.
    public var order: Double = 0

    /// Separator to be inserted between logs.
    /// By default, it is equal to `\n`.
    public var delimeter: String

    /// Next log.
    public var next: Logable?

    /// The content of this log.
    public var message: String

    /// Log identifier.
    public var id: String

    /// Initializes the object.
    ///
    /// - Parameters:
    ///   - message: The content of this log.
    ///   - delimeter: Separator to be inserted between logs. By default, it is equal to `\n`.
    public init(_ message: String, id: String, delimeter: String = "\n", order: Double = 0) {
        self.message = message
        self.delimeter = delimeter
        self.id = id
        self.order = order
    }

    /// Appends `delimeter` to its own `message`, then appends `next.description` to the resulting string.
    public var description: String {
        let result = self.delimeter + message + self.delimeter

        return result + (self.next?.description ?? "")
    }

    /// Adds a message to the log.
    ///
    /// - Parameter message: Log message.
    mutating public func add(message: String) {
        self.message += message
    }

    /// Syntactic sugar for add(message:)
    public static func += (lhs: inout Log, rhs: String) {
        lhs.add(message: rhs)
    }
}
