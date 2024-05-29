import Foundation

/// This node translates a generic request into a specific implementation.
/// It works with URL requests, over the HTTP protocol with JSON.
open class URLRequestTrasformatorNode<Type>: AsyncNode {

    /// The next node for processing.
    public var next: any AsyncNode<RequestEncodingModel, Type>

    /// HTTP method for the request.
    public var method: Method

    /// Initializes the node.
    ///
    /// - Parameters:
    ///   - next: The next node for processing.
    ///   - method: The HTTP method for the request.
    public init(next: some AsyncNode<RequestEncodingModel, Type>, method: Method) {
        self.next = next
        self.method = method
    }

    /// Constructs a model for operation at the transport level of the chain.
    ///
    /// - Parameter data: Data for further processing.
    open func process(
        _ data: EncodableRequestModel<URLRouteProvider, Json, ParametersEncoding?>,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Type> {
        await .withMappedExceptions {
            .success(try data.route.url())
        }
        .asyncFlatMap { url in
            await .withCheckedCancellation {
                let params = TransportURLParameters(
                    method: method,
                    url: url,
                    headers: data.metadata
                )
                let encodingModel = RequestEncodingModel(
                    urlParameters: params,
                    raw: data.raw,
                    encoding: data.encoding ?? nil
                )
                return await next.process(encodingModel, logContext: logContext)
            }
        }
    }
}
