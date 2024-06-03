import Foundation

/// Model for internal representation of a request.
public struct TransportURLRequest {

    /// HTTP method.
    public let method: Method
    /// URL endpoint.
    public let url: URL
    /// Request headers.
    public let headers: [String: String]
    /// Raw `Data`.
    public let raw: Data?

    /// Initializes the object.
    ///
    /// - Parameters:
    ///   - params: Parameters for forming the request.
    ///   - raw: Data for the request in `Data` format.
    public init(with params: TransportURLParameters, raw: Data?) {
        self.init(method: params.method,
                  url: params.url,
                  headers: params.headers,
                  raw: raw)
    }

    public init(method: Method,
                url: URL,
                headers: [String: String],
                raw: Data?) {
        self.method = method
        self.url = url
        self.headers = headers
        self.raw = raw
    }

}
