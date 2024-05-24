import Foundation

/// Ошибки для узла `URLQueryInjectorNode`
public enum URLQueryInjectorNodeError: Error {
    /// Возникает в случае, если не удалось создать URLComponents из URL
    case cantCreateURLComponentsFromURLString
    /// Возникает в случае, если построить URLComponents удалось, а вот получить из него URL - нет.
    case cantCreateURLFromURLComponents
}

/// Узел, который позволяет добавить данные в URL-Query.
///
/// То есть этот узел позволяет добавить данные для запроса в любой http-запрос.
/// Вне зависимости от его метода.
///
/// - Info:
/// Использовать можно после `RequestRouterNode`.
open class URLQueryInjectorNode<Raw, Output>: AsyncNode {

    // MARK: - Nested

    /// Тип ошибки для этого узла.
    public typealias NodeError = URLQueryInjectorNodeError

    // MARK: - Properties

    /// Следующий по порядку узел.
    open var next: any AsyncNode<RoutableRequestModel<URLRouteProvider, Raw>, Output>

    open var config: URLQueryConfigModel

    // MARK: - Init

    /// Инцииаллизирует объект.
    /// - Parameter next: Следующий по порядку узел.
    /// - Parameter config: Конфигурация для узла.
    public init(
        next: any AsyncNode<RoutableRequestModel<URLRouteProvider, Raw>, Output>,
        config: URLQueryConfigModel
    ) {
        self.next = next
        self.config = config
    }

    // MARK: - Public methods

    /// Добавляет URL-query если может и передает управление следующему узлу.
    /// В случае, если не удалось обработать URL, то возвращает ошибку `cantCreateURLComponentsFromURLString`
    /// - SeeAlso: ``URLQueryInjectorNodeError``
    open func process(
        _ data: RoutableRequestModel<URLRouteProvider, Raw>,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        return await .withMappedExceptions {
            return try await transform(from: data)
                .asyncFlatMap { result in
                    return await next.process(result, logContext: logContext)
                }
        }
    }

    /// Позволяет получить список компонент URL-query, по ключу и значению.
    /// - Parameter object: Значение параметра URL-query.
    /// - Parameter key: Ключ параметра URL-query.
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
