import Foundation

/// Этот узел переводит Generic запрос в конкретную реализацию.
/// Данный узел работает с URL-запросами, по HTTP протоколу с JSON
open class UrlRequestTrasformatorNode<Type>: Node<EncodableRequestModel<UrlRouteProvider, Data, ParametersEncoding>, Type> {

    /// Следйющий узел для обработки.
    public var next: Node<TransportUrlRequest, Type>

    /// HTTP метод для запроса.
    public var method: Method

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следйющий узел для обработки.
    ///   - method: HTTP метод для запроса.
    public init(next: Node<TransportUrlRequest, Type>, method: Method) {
        self.next = next
        self.method = method
    }

    /// Конструирует модель для для работы на транспортном уровне цепочки.
    ///
    /// - Parameter data: Данные для дальнейшей обработки.
    open override func process(_ data: EncodableRequestModel<UrlRouteProvider, Data, ParametersEncoding>) -> Observer<Type> {

        var url: URL

        do {
            url = try data.route.url()
        } catch {
            return .emit(error: error)
        }

        let params = TransportUrlParameters(method: self.method,
                                            url: url,
                                            headers: data.metadata,
                                            parametersEncoding: data.encoding)

        let request = TransportUrlRequest(with: params, raw: data.raw)

        return next.process(request)
    }
}
