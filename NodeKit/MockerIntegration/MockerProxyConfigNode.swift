import Foundation

public enum MockerProxyConfigKey {
    public static let isProxyingOn = "X-Mocker-Redirect-Is-On"
    public static let proxyingHost = "X-Mocker-Redirect-Host"
    public static let proxyingScheme = "X-Mocker-Redirect-Scheme"
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
open class MockerProxyConfigNode<Raw, Output>: AsyncNode {
    
    private typealias Keys = MockerProxyConfigKey

    // MARK: - Public Properties

    /// Следующий в цепочке узел.
    open var next: any AsyncNode<RequestModel<Raw>, Output>

    /// Указывает, включено ли проексирование.
    open var isProxyingOn: Bool
    /// Адрес хоста (опционально с портом) которому будет переадресован запрос.
    open var proxyingHost: String
    /// Схема (http/https etc).
    open var proxyingScheme: String

    // MARK: - Init

    /// Инициаллизирует узел
    ///
    /// - Parameters:
    ///   - next: Следующий в цепочке узел.
    ///   - isProxyingOn: Указывает, включено ли проексирование.
    ///   - proxyingHost: Адрес хоста (опционально с портом) которому будет переадресован запрос.
    ///   - proxyingSchema: Схема (http/https etc).
    public init(next: some AsyncNode<RequestModel<Raw>, Output>,
                isProxyingOn: Bool,
                proxyingHost: String = "",
                proxyingScheme: String = "") {
        self.next = next
        self.isProxyingOn = isProxyingOn
        self.proxyingHost = proxyingHost
        self.proxyingScheme = proxyingScheme
    }

    // MARK: - Node

    /// Добавляет хедеры в `data`
    open func processLegacy(_ data: RequestModel<Raw>) -> Observer<Output> {

        guard self.isProxyingOn else {
            return self.next.processLegacy(data)
        }

        var copy = data

        copy.metadata[Keys.isProxyingOn] = String(self.isProxyingOn)
        copy.metadata[Keys.proxyingHost] = self.proxyingHost
        copy.metadata[Keys.proxyingScheme] = self.proxyingScheme

        return self.next.processLegacy(copy)
    }

    // MARK: - Node

    /// Добавляет хедеры в `data`
    open func process(
        _ data: RequestModel<Raw>,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        guard isProxyingOn else {
            return await next.process(data, logContext: logContext)
        }

        var copy = data

        copy.metadata[Keys.isProxyingOn] = String(isProxyingOn)
        copy.metadata[Keys.proxyingHost] = proxyingHost
        copy.metadata[Keys.proxyingScheme] = proxyingScheme

        return await next.process(copy, logContext: logContext)
    }
}
