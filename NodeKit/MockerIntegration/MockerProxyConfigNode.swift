import Foundation

fileprivate enum MockerProxyConfigKey {
    static let isProxyingOn = "X-Mocker-Redirect-Is-On"
    static let proxyingHost = "X-Mocker-Redirect-Host"
    static let proxyingSchema = "X-Mocker-Redirect-Scheme"
}

/// Этот узел добавляет специальные хедеры для конфигурирования функции проксирования у Mocker.
///
/// Этот узел нужно вставлять в слой построения запроса (RequestBuildingLayer)
/// после `MetadataConnectorNode`, но до `RequestRouterNode`
///
/// Подробнее об этой функции в Mocker можно прочесть [здесь](https://github.com/LastSprint/mocker#проксирование)
///
/// - SeeAlso:
///     - `MetadataConnectorNode`
///     - `RequestRouterNode`
final class MockerProxyConfigNode<Raw, Output>: Node<RequestModel<Raw>, Output> {

    private typealias Keys = MockerProxyConfigKey

    // MARK: - Public Properties

    /// Следующий в цепочке узел.
    public var next: Node<RequestModel<Raw>, Output>

    /// Указывает, включено ли проексирование.
    public var isProxyingOn: Bool
    /// Адрес хоста (опционально с портом) которому будет переадресован запрос.
    public var proxyingHost: String
    /// Схема (http/https etc).
    public var proxyingSchema: String

    // MARK: - Init

    /// Инициаллизирует узел
    ///
    /// - Parameters:
    ///   - next: Следующий в цепочке узел.
    ///   - isProxyingOn: Указывает, включено ли проексирование.
    ///   - proxyingHost: Адрес хоста (опционально с портом) которому будет переадресован запрос.
    ///   - proxyingSchema: Схема (http/https etc).
    public init(next: Node<RequestModel<Raw>, Output>,
                isProxyingOn: Bool,
                proxyingHost: String,
                proxyingSchema: String) {
        self.next = next
        self.isProxyingOn = isProxyingOn
        self.proxyingHost = proxyingHost
        self.proxyingSchema = proxyingSchema
    }

    // MARK: - Node

    /// Добавляет хедеры в `data`
    override func process(_ data: RequestModel<Raw>) -> Observer<Output> {

        var copy = data

        copy.metadata[Keys.isProxyingOn] = String(self.isProxyingOn)
        copy.metadata[Keys.proxyingHost] = self.proxyingHost
        copy.metadata[Keys.proxyingSchema] = self.proxyingSchema

        return self.next.process(copy)
    }
}
