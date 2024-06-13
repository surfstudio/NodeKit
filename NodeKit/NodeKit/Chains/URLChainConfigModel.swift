import Foundation

/// Model for configuring the transformation chain for network requests.
public struct URLChainConfigModel {
    
    /// HTTP method to be used by the chain.
    public let method: Method

    /// Route to the remote method (specifically, the URL endpoint).
    public let route: URLRouteProvider

    /// In the case of classic HTTP, these are the request headers.
    /// By default, empty.
    public let metadata: [String: String]

    /// Data encoding for the request.
    ///
    /// By default, `.json`.
    public let encoding: ParametersEncoding

    /// Initializes the object.
    ///
    /// - Parameters:
    ///   - method: HTTP method to be used by the chain
    ///   - route: Route to the remote method
    ///   - metadata: In the case of classic HTTP, these are the request headers. Default is empty.
    ///   - encoding: Data encoding for the request. Default is `.json`.
    public init(method: Method,
         route: URLRouteProvider,
         metadata: [String: String] = [:],
         encoding: ParametersEncoding = .json) {
        self.method = method
        self.route = route
        self.metadata = metadata
        self.encoding = encoding
    }
}
