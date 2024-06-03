import Foundation

/// This node translates a generic request into a specific implementation.
/// It works with URL requests over the HTTP protocol with JSON.
open class MultipartURLRequestTrasformatorNode<Type>: AsyncNode {

    /// The next node for processing.
    open var next: any AsyncNode<MultipartURLRequest, Type>

    /// HTTP method for the request.
    open var method: Method

    /// Initializer.
    ///
    /// - Parameters:
    ///   - next: The next node for processing.
    ///   - method: The HTTP method for the request.
    public init(next: any AsyncNode<MultipartURLRequest, Type>, method: Method) {
        self.next = next
        self.method = method
    }

    /// Constructs a model for operation at the transport level of the chain.
    ///
    /// - Parameter data: Data for further processing.
    open func process(
        _ data: RoutableRequestModel<URLRouteProvider, MultipartModel<[String : Data]>>,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Type> {
        await .withMappedExceptions {
            .success(try data.route.url())
        }
        .asyncFlatMap { url in
            await .withCheckedCancellation {
                let request = MultipartURLRequest(
                    method: method,
                    url: url,
                    headers: data.metadata,
                    data: data.raw
                )
                return await next.process(request, logContext: logContext)
            }
        }
    }
}
