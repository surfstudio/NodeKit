import Foundation

/// The task of this node is to add metadata to the created request.
/// Initializes the chain for building an HTTP request.
open class MetadataConnectorNode<Raw, Output>: AsyncNode {

    /// The next node for processing.
    public var next: any AsyncNode<RequestModel<Raw>, Output>

    /// Metadata for request.
    public var metadata: [String: String]

    /// Initializes the node.
    ///
    /// - Parameters:
    ///   - next: The next node in the chain.
    ///   - metadata: Metadata for the request.
    public init(next: some AsyncNode<RequestModel<Raw>, Output>, metadata: [String: String]) {
        self.next = next
        self.metadata = metadata
    }

    /// Forms the ``RequestModel`` and passes it for further processing.
    ///
    /// - Parameter data: Data in raw format. (after mapping from Entry)
    open func process(
        _ data: Raw,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await .withCheckedCancellation {
            await next.process(
                RequestModel(metadata: metadata, raw: data),
                logContext: logContext
            )
        }
    }
}
