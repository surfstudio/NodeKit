//
//  LogableChain.swift
//
//  Created by Александр Кравченков on 07/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Describes an entity that contains a description for the work log.
public protocol LogableChain: Log {

    /// Next log.
    var next: LogableChain? { get set }

    /// Entire chain of logs with the specified formatting.
    var description: String { get }

    /// Formatted description with id.
    var printString: String { get }

    /// Adds a message to the log.
    ///
    /// - Parameter message: Log message.
    mutating func add(message: String)
}

extension LogableChain {
    /// Converts a tree-like structure of log entries into an array
    /// using non-recursive depth-first traversal.
    func flatMap() -> [LogableChain] {
        var currentLogable: LogableChain? = self
        var result = [LogableChain]()
        while currentLogable != nil {
            guard var log = currentLogable else { break }
            currentLogable = log.next
            log.next = nil
            result.append(log)
        }
        return result
    }
}
