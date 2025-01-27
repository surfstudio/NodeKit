//
//  LoggerStreamNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

/// This node performs logging to the console.
/// Immediately passes control to the next node and subscribes to perform operations.
class LoggerStreamNode<Input, Output>: AsyncStreamNode {
    
    /// The next node for processing.
    var next: any AsyncStreamNode<Input, Output>
    ///List of keys by which the log will be filtered.
    var filters: [String]

    /// Initializer.
    ///
    /// - Parameters:
    ///   - next: The next node for processing.
    ///   - filters: List of keys by which the log will be filtered.
    init(next: any AsyncStreamNode<Input, Output>, filters: [String] = []) {
        self.next = next
        self.filters = filters
    }

    /// Immediately passes control to the next node and subscribes to perform operations.
    ///
    /// - Parameter data: Data for processing. This node does not use them.
    func process(_ data: Input, logContext: LoggingContextProtocol) -> AsyncStream<NodeResult<Output>> {
        return AsyncStream { continuation in
            let task = Task {
                for await result in next.process(data, logContext: logContext) {
                    continuation.yield(result)
                }
                await logContext.log?.flatMap()
                    .filter { !filters.contains($0.id) }
                    .sorted(by: { $0.order < $1.order })
                    .forEach { print($0.printString) }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
