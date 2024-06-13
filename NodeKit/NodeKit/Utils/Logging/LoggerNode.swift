import Foundation

/// This node performs logging to the console.
/// Immediately passes control to the next node and subscribes to perform operations.
open class LoggerNode<Input, Output>: AsyncNode {

    /// The next node for processing.
    open var next: any AsyncNode<Input, Output>
    ///List of keys by which the log will be filtered.
    open var filters: [String]

    /// Initializer.
    ///
    /// - Parameters:
    ///   - next: The next node for processing.
    ///   - filters: List of keys by which the log will be filtered.
    public init(next: any AsyncNode<Input, Output>, filters: [String] = []) {
        self.next = next
        self.filters = filters
    }

    /// Immediately passes control to the next node and subscribes to perform operations.
    ///
    /// - Parameter data: Data for processing. This node does not use them.
    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        let result = await next.process(data, logContext: logContext)

        await logContext.log?.flatMap()
            .filter { !filters.contains($0.id) }
            .sorted(by: { $0.order < $1.order })
            .forEach {
                print($0.description)
            }

        return result
    }
}
