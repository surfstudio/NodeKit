import Foundation

/// Модель для внутреннего представления запроса.
public struct TransportUrlRequest {

    /// HTTP метод.
    public let method: Method
    /// URL эндпоинта.
    public let url: URL
    /// Хедеры запроса.
    public let headers: [String: String]
    /// Данные для запроса в формате `JSON`
    public let raw: Json
    /// Кодировка данных для запроса.
    public let parametersEncoding: ParametersEncoding

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - params: Параметры для формирования запроса.
    ///   - raw: Данные для запроса в формате `JSON`
    public init(with params: TransportUrlParameters, raw: Json) {
        self.init(method: params.method,
                  url: params.url,
                  headers: params.headers,
                  raw: raw,
                  parametersEncoding: params.parametersEncoding)
    }

    public init(method: Method,
                url: URL,
                headers: [String: String],
                raw: Json,
                parametersEncoding: ParametersEncoding) {
        self.method = method
        self.url = url
        self.headers = headers
        self.raw = raw
        self.parametersEncoding = parametersEncoding
    }
}
