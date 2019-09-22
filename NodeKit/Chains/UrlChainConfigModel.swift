import Foundation

/// Модель данных для конфигурироания цепочки преобразований для запроса в сеть.
public struct UrlChainConfigModel {
    
    /// HTTP метод, который будет использован цепочкой
    public let method: Method

    /// Маршрут до удаленного метода (в частном случае - URL endpoint'a)
    public let route: UrlRouteProvider

    /// В случае классического HTTP это Header'ы запроса.
    /// По-умолчанию пустой.
    public let metadata: [String: String]

    /// Кодировка данных для запроса.
    /// По умолчанию`.json`
    public let encoding: ParametersEncoding

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - method: HTTP метод, который будет использован цепочкой
    ///   - route: Маршрут до удаленного метод
    ///   - metadata: В случае классического HTTP это Header'ы запроса. По-умолчанию пустой.
    ///   - encoding: Кодировка данных для запроса. По-умолчанию `.json`
    public init(method: Method,
         route: UrlRouteProvider,
         metadata: [String: String] = [:],
         encoding: ParametersEncoding = .json) {
        self.method = method
        self.route = route
        self.metadata = metadata
        self.encoding = encoding
    }
}
