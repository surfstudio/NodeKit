//
//  LogWrapper.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 07/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Describes an entity that contains a description for the work log.
public protocol Logable {

    /// The order of the log in the chain. Necessary for sorting.
    var order: Double { get }

    /// Next log.
    var next: Logable? { get set }

    /// Log identifier.
    var id: String { get }

    /// Entire chain of logs with the specified formatting.
    var description: String { get }

    /// Adds a message to the log.
    ///
    /// - Parameter message: Log message.
    mutating func add(message: String)
}

extension Logable {
    /// Converts a tree-like structure of log entries into an array
    /// using non-recursive depth-first traversal.
    func flatMap() -> [Logable] {
        var currentLogable: Logable? = self
        var result = [Logable]()
        while currentLogable != nil {
            guard var log = currentLogable else { break }
            currentLogable = log.next
            log.next = nil
            result.append(log)
        }
        return result
    }
}
