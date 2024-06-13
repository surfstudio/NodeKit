import Foundation

/// Errors for ``URLQueryInjectorNode``
public enum URLQueryInjectorNodeError: Error {
    /// Occurs if URLComponents could not be created from the URL.
    case cantCreateURLComponentsFromURLString
    /// Occurs if building URLComponents succeeded but obtaining the URL from it failed.
    case cantCreateURLFromURLComponents
}

/// Node that allows adding data to the URL-Query.
///
/// This node enables adding data for the request in any HTTP request, regardless of its method.
///
/// - Info:
/// Can be used after ``RequestRouterNode``.
open class URLQueryInjectorNode<Raw, Output>: AsyncNode {

    // MARK: - Nested

    /// Error type for this node.
    public typealias NodeError = URLQueryInjectorNodeError

    // MARK: - Properties

    /// The next node for processing.
    open var next: any AsyncNode<RoutableRequestModel<URLRouteProvider, Raw>, Output>

    /// Configuration for the node.
    open var config: URLQueryConfigModel

    // MARK: - Init

    /// Initializes the object.
    /// - Parameter next: The next node in the sequence.
    /// - Parameter config: Configuration for the node.
    public init(
        next: any AsyncNode<RoutableRequestModel<URLRouteProvider, Raw>, Output>,
        config: URLQueryConfigModel
    ) {
        self.next = next
        self.config = config
    }

    // MARK: - Public methods

    /// Adds a URL query if possible and passes control to the next node.
    /// If it fails to process the URL, it returns the error `cantCreateURLComponentsFromURLString`.
    open func process(
        _ data: RoutableRequestModel<URLRouteProvider, Raw>,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await .withMappedExceptions {
            try await transform(from: data)
        }
        .asyncFlatMap { result in
            await .withCheckedCancellation {
                await next.process(result, logContext: logContext)
            }
        }
    }

    /// Allows to obtain a list of URL query components by key and value.
    /// - Parameter object: The value of the URL query parameter.
    /// - Parameter key: The key of the URL query parameter.
    open func makeQueryComponents(from object: Any, by key: String) -> [URLQueryItem] {

        var items = [URLQueryItem]()

        switch object {
        case let casted as [Any]:
            let key = self.config.arrayEncodingStrategy.encode(value: key)
            items += casted.map { self.makeQueryComponents(from: $0, by: key) }.reduce([], { $0 + $1 })
        case let casted as [String: Any]:

            items += casted
                .map { dictKey, value in
                    let realKey = self.config.dictEncodindStrategy.encode(queryItemName: key, dictionaryKey: dictKey)
                    return self.makeQueryComponents(from: value, by: realKey)
                }.reduce([], { $0 + $1 })

        case let casted as Bool:
            items.append(.init(name: key, value: self.config.boolEncodingStartegy.encode(value: casted)))
        default:
            items.append(.init(name: key, value: "\(object)"))
        }

        return items
    }

    private func transform(
        from data: RoutableRequestModel<URLRouteProvider, Raw>
    ) async throws -> NodeResult<RoutableRequestModel<URLRouteProvider, Raw>> {
        guard !config.query.isEmpty else {
            return .success(data)
        }
        return await urlComponents(try data.route.url())
            .flatMap {
                guard let url = $0.url else {
                    return .failure(NodeError.cantCreateURLFromURLComponents)
                }
                return .success(url)
            }
            .map {
                return RoutableRequestModel<URLRouteProvider, Raw>(
                    metadata: data.metadata,
                    raw: data.raw,
                    route: $0
                )
            }
    }

    private func urlComponents(_ url: URL) async -> NodeResult<URLComponents> {
        guard var urlComponents = URLComponents(string: url.absoluteString) else {
            return .failure(NodeError.cantCreateURLComponentsFromURLString)
        }
        urlComponents.queryItems = config.query
            .map { makeQueryComponents(from: $1, by: $0) }
            .reduce([], { $0 + $1 })
            .sorted(by: { $0.name < $1.name })
        return .success(urlComponents)
    }
}
