import Foundation

/// Ошибки для узла `URLQueryInjectorNode`
public enum URLQueryInjectorNodeError: Error {
    /// Возникает в случае, если не удалось создать URLComponents из URL
    case cantCreateUrlComponentsFromUrlString
    /// Возникает в случае, если построить URLComponents удалось, а вот получить из него URL - нет.
    case cantCreateUrlFromUrlComponents
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
    open var next: any AsyncNode<RoutableRequestModel<UrlRouteProvider, Raw>, Output>

    open var config: URLQueryConfigModel

    // MARK: - Init

    /// Инцииаллизирует объект.
    /// - Parameter next: Следующий по порядку узел.
    /// - Parameter config: Конфигурация для узла.
    public init(
        next: any AsyncNode<RoutableRequestModel<UrlRouteProvider, Raw>, Output>,
        config: URLQueryConfigModel
    ) {
        self.next = next
        self.config = config
    }

    // MARK: - Public methods

    /// Добавляет URL-query если может и передает управление следующему узлу.
    /// В случае, если не удалось обработать URL, то возвращает ошибку `cantCreateUrlComponentsFromUrlString`
    /// - SeeAlso: ``URLQueryInjectorNodeError``
    open func process(_ data: RoutableRequestModel<UrlRouteProvider, Raw>) -> Observer<Output> {

        guard !self.config.query.isEmpty else {
            return self.next.process(data)
        }

        var url: URL

        do {
            url = try data.route.url()
        } catch {
            return .emit(error: error)
        }

        guard var urlComponents = URLComponents(string: url.absoluteString) else {
            return .emit(error: NodeError.cantCreateUrlComponentsFromUrlString)
        }

        urlComponents.queryItems = self.config.query
            .map { self.makeQueryComponents(from: $1, by: $0) }
            .reduce([], { $0 + $1 })
            .sorted(by: { $0.name < $1.name })

        guard let newUrl = urlComponents.url else {
            return .emit(error: NodeError.cantCreateUrlFromUrlComponents)
        }

        let newModel = RoutableRequestModel<UrlRouteProvider, Raw>(metadata: data.metadata,
                                                                   raw: data.raw,
                                                                   route: newUrl)

        return self.next.process(newModel)
    }

    /// Добавляет URL-query если может и передает управление следующему узлу.
    /// В случае, если не удалось обработать URL, то возвращает ошибку `cantCreateUrlComponentsFromUrlString`
    /// - SeeAlso: ``URLQueryInjectorNodeError``
    open func process(
        _ data: RoutableRequestModel<UrlRouteProvider, Raw>,
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
        from data: RoutableRequestModel<UrlRouteProvider, Raw>
    ) async throws -> NodeResult<RoutableRequestModel<UrlRouteProvider, Raw>> {
        guard !config.query.isEmpty else {
            return .success(data)
        }
        return await urlComponents(try data.route.url())
            .flatMap {
                guard let url = $0.url else {
                    return .failure(NodeError.cantCreateUrlFromUrlComponents)
                }
                return .success(url)
            }
            .map {
                return RoutableRequestModel<UrlRouteProvider, Raw>(
                    metadata: data.metadata,
                    raw: data.raw,
                    route: $0
                )
            }
    }

    private func urlComponents(_ url: URL) async -> NodeResult<URLComponents> {
        guard var urlComponents = URLComponents(string: url.absoluteString) else {
            return .failure(NodeError.cantCreateUrlComponentsFromUrlString)
        }
        urlComponents.queryItems = config.query
            .map { makeQueryComponents(from: $1, by: $0) }
            .reduce([], { $0 + $1 })
            .sorted(by: { $0.name < $1.name })
        return .success(urlComponents)
    }
}
