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
open class URLQueryInjectorNode<Raw, Output>: Node<RoutableRequestModel<UrlRouteProvider, Raw>, Output> {

    // MARK: - Nested

    /// Тип ошибки для этого узла.
    public typealias Error = URLQueryInjectorNodeError

    // MARK: - Properties

    /// Следующий по порядку узел.
    open var next: Node<RoutableRequestModel<UrlRouteProvider, Raw>, Output>

    open var config: URLQueryConfigModel

    // MARK: - Init

    /// Инцииаллизирует объект.
    /// - Parameter next: Следующий по порядку узел.
    /// - Parameter config: Конфигурация для узла.
    public init(next: Node<RoutableRequestModel<UrlRouteProvider, Raw>, Output>, config: URLQueryConfigModel) {

        self.next = next
        self.config = config
    }

    // MARK: - Public methods

    /// Добавляет URL-query если может и передает управление следующему узлу.
    /// В случае, если не удалось обработать URL, то возвращает ошибку `cantCreateUrlComponentsFromUrlString`
    /// - SeeAlso: `URLQueryInjectorNodeError`
    open override func process(_ data: RoutableRequestModel<UrlRouteProvider, Raw>) -> Observer<Output> {

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
            return .emit(error: Error.cantCreateUrlComponentsFromUrlString)
        }

        urlComponents.queryItems = self.config.query
            .map { self.makeQueryComponents(from: $1, by: $0) }
            .reduce([], { $0 + $1 })

        guard let newUrl = urlComponents.url else {
            return .emit(error: Error.cantCreateUrlFromUrlComponents)
        }

        let newModel = RoutableRequestModel<UrlRouteProvider, Raw>(metadata: data.metadata,
                                                                   raw: data.raw,
                                                                   route: newUrl)

        return self.next.process(newModel)
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
}
