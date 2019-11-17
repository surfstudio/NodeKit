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
/// Использовать можно после `UrlRequestTrasformatorNode`.
open class URLQueryInjectorNode<Type>: Node<TransportUrlRequest, Type> {

    // MARK: - Nested

    /// Тип ошибки для этого узла.
    public typealias Error = URLQueryInjectorNodeError

    // MARK: - Properties

    /// Следующий по порядку узел.
    open var next: Node<TransportUrlRequest, Type>

    /// Модель из которой создается URL-query.
    open var query: [String: Any]

    /// Стратегия для кодирования булевых значений.
    /// - SeeAlso: `URLQueryBoolEncodingDefaultStartegy`
    open var boolEncodingStartegy: URLQueryBoolEncodingStartegy

    /// Стратегия для кодирования ключа массива.
    /// - SeeAlso: `URLQueryArrayKeyEncodingBracketsStartegy`
    open var arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy

    /// Стратегия для кодирования ключа словаря.
    /// - SeeAlso: `URLQueryDictionaryKeyEncodingDefaultStrategy`
    open var dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy

    // MARK: - Init

    /// Инцииаллизирует объект.
    /// - Parameter next: Следующий по порядку узел.
    /// - Parameter query: Модель из которой создается URL-query.
    /// - Parameter boolEncodingStartegy: Стратегия для кодирования булевых значений.
    /// - Parameter arrayEncodingStrategy: Стратегия для кодирования ключа массива.
    /// - Parameter dictEncodindStrategy: Стратегия для кодирования ключа словаря.
    public init(next: Node<TransportUrlRequest, Type>,
                query: [String: Any],
                boolEncodingStartegy: URLQueryBoolEncodingStartegy,
                arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy,
                dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy) {

        self.next = next
        self.query = query
        self.boolEncodingStartegy = boolEncodingStartegy
        self.arrayEncodingStrategy = arrayEncodingStrategy
        self.dictEncodindStrategy = dictEncodindStrategy
    }

    /// Инцииаллизирует объект.
    /// - Parameter next: Следующий по порядку узел.
    /// - Parameter query: Модель из которой создается URL-query.
    ///
    /// - Info:
    ///     - `boolEncodingStartegy` = `URLQueryBoolEncodingDefaultStartegy.asInt`
    ///     - `arrayEncodingStrategy` = `URLQueryArrayKeyEncodingBracketsStartegy.brackets`
    ///     - `dictEncodindStrategy` = `URLQueryDictionaryKeyEncodingDefaultStrategy`
    public convenience init(next: Node<TransportUrlRequest, Type>, query: [String: Any]) {
        self.init(next: next,
                  query: query,
                  boolEncodingStartegy: URLQueryBoolEncodingDefaultStartegy.asInt,
                  arrayEncodingStrategy: URLQueryArrayKeyEncodingBracketsStartegy.brackets,
                  dictEncodindStrategy: URLQueryDictionaryKeyEncodingDefaultStrategy())
    }

    // MARK: - Public methods

    /// Добавляет URL-query если может и передает управление следующему узлу.
    /// В случае, если не удалось обработать URL, то возвращает ошибку `cantCreateUrlComponentsFromUrlString`
    /// - SeeAlso: `URLQueryInjectorNodeError`
    open override func process(_ data: TransportUrlRequest) -> Observer<Type> {

        guard !self.query.isEmpty else {
            return self.next.process(data)
        }

        guard var urlComponents = URLComponents(string: data.url.absoluteString) else {
            return .emit(error: Error.cantCreateUrlComponentsFromUrlString)
        }

        urlComponents.queryItems = self.query.map { self.makeQueryComponents(from: $1, by: $0) }.reduce([], { $0 + $1 })

        guard let url = urlComponents.url else {
            return .emit(error: Error.cantCreateUrlFromUrlComponents)
        }

        return self.next.process(.init(method:
                                       data.method,
                                       url: url,
                                       headers: data.headers,
                                       raw: data.raw,
                                       parametersEncoding: data.parametersEncoding))
    }

    /// Позволяет получить список компонент URL-query, по ключу и значению.
    /// - Parameter object: Значение параметра URL-query.
    /// - Parameter key: Ключ параметра URL-query.
    open func makeQueryComponents(from object: Any, by key: String) -> [URLQueryItem] {

        var items = [URLQueryItem]()

        switch object {
        case let casted as [Any]:
            let key = self.arrayEncodingStrategy.encode(value: key)
            items += casted.map { self.makeQueryComponents(from: $0, by: key) }.reduce([], { $0 + $1 })
        case let casted as [String: Any]:

            items += casted
                .map { dictKey, value in
                    let realKey = self.dictEncodindStrategy.encode(queryItemName: key, dictionaryKey: dictKey)
                    return self.makeQueryComponents(from: value, by: realKey)
                }.reduce([], { $0 + $1 })

        case let casted as Bool:
            items.append(.init(name: key, value: self.boolEncodingStartegy.encode(value: casted)))
        default:
            items.append(.init(name: key, value: "\(object)"))
        }

        return items
    }
}
