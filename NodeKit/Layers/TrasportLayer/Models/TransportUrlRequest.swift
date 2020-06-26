import Foundation

/// Модель для внутреннего представления запроса.
public struct TransportUrlRequest {

    /// HTTP метод.
    public let method: Method
    /// URL эндпоинта.
    public let url: URL
    /// Хедеры запроса.
    public let headers: [String: String]
    /// Данные для запроса в чистой `Data`
    public let raw: Data?

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - params: Параметры для формирования запроса.
    ///   - raw: Данные для запроса в формате `Data`
    public init(with params: TransportUrlParameters, raw: Data?) {
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
