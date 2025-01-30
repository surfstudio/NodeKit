import Foundation

/// This node initializes the URL request.
open class RequestCreatorNode<Output>: AsyncNode {

    /// The next node for processing.
    public var next: any AsyncNode<URLRequest, Output>

    /// Metadata providers
    public var providers: [MetadataProvider]

    /// Initializer.
    ///
    /// - Parameter next: The next node for processing.
    public init(next: some AsyncNode<URLRequest, Output>, providers: [MetadataProvider] = []) {
        self.next = next
        self.providers = providers
    }

    /// Configures the low-level request.
    ///
    /// - Parameter data: Data for configuring and subsequently sending the request.
    open func process(
        _ data: TransportURLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await .withCheckedCancellation {
            var mergedHeaders = data.headers

            providers.map { $0.metadata() }.forEach { dict in
                mergedHeaders.merge(dict, uniquingKeysWith: { $1 })
            }

            var request = URLRequest(url: data.url)
            request.httpMethod = data.method.rawValue
            request.httpBody = data.raw
            mergedHeaders.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

            await logContext.add(getLogMessage(data))
            return await next.process(request, logContext: logContext)
        }
    }

    private func getLogMessage(_ data: TransportURLRequest) -> LogChain {
        var message = "input: \(type(of: data))\n"
        message += "method: \(data.method.rawValue)\n"
        message += "url: \(data.url.absoluteString)\n"
        message += "headers: \(data.headers)\n"
        message += "raw: \(serilizeDataForLog(data: data.raw))\n"

        return LogChain(message, id: self.objectName, logType: .info, order: LogOrder.requestCreatorNode)
    }

    private func serilizeDataForLog(data: Data?) -> String {
        guard let data = data, let parsed = String(data: data, encoding: .utf8) else {
            return String(describing: data)
        }
        return parsed
    }

}
