import Foundation

/// This node performs logging to the console.
/// Immediately passes control to the next node and subscribes to perform operations.
open class LoggerNode<Input, Output>: AsyncNode {

    /// The next node for processing.
    open var next: any AsyncNode<Input, Output>
    ///List of keys by which the log will be filtered.
    open var filters: [String]

    /// Request method.
    private let method: Method?
    /// URL route.
    private let route: URLRouteProvider?
    /// Logging proxy.
    private let loggingProxy: LoggingProxy?

    /// Initializer.
    ///
    /// - Parameters:
    ///   - next: The next node for processing.
    ///   - method: Request method.
    ///   - route: URL route.
    ///   - filters: List of keys by which the log will be filtered.
    public init(
        next: any AsyncNode<Input, Output>,
        method: Method?,
        route: URLRouteProvider?,
        loggingProxy: LoggingProxy?,
        filters: [String] = []
    ) {
        self.next = next
        self.method = method
        self.route = route
        self.loggingProxy = loggingProxy
        self.filters = filters
    }

    /// Immediately passes control to the next node and subscribes to perform operations.
    ///
    /// - Parameter data: Data for processing. This node does not use them.
    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await prepare(logContext: logContext)
        let result = await next.process(data, logContext: logContext)
            .asyncFlatMapError {
                await set(error: $0, in: logContext)
                return .failure($0)
            }
        await finish(logContext: logContext)
        return result
    }

}

private extension LoggerNode {

    func prepare(logContext: LoggingContextProtocol) async {
        await logContext.set(method: method, route: route)
        await loggingProxy?.handle(session: logContext)
    }

    func set(error: Error, in logContext: LoggingContextProtocol) async {
        let log = LogChain(
            "Request failed: \(error)",
            id: objectName,
            logType: .failure,
            order: LogOrder.loggerNode
        )
        await logContext.add(log)
    }

    func finish(logContext: LoggingContextProtocol) async {
        await logContext.complete()
        if loggingProxy == nil {
            await logContext.log?.flatMap()
                .filter { !filters.contains($0.id) }
                .sorted(by: { $0.order < $1.order })
                .forEach {
                    print($0.printString)
                }
        }
    }

}
