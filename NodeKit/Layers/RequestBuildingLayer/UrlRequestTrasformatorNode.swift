import Foundation
import Combine

/// Этот узел переводит Generic запрос в конкретную реализацию.
/// Данный узел работает с URL-запросами, по HTTP протоколу с JSON
open class UrlRequestTrasformatorNode<Type>: Node<EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding>, Type> {

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
    open override func process(_ data: EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding>) -> Observer<Type> {

        var request: TransportUrlRequest

        do {
            request = try self.transform(data: data)
        } catch {
            return .emit(error: error)
        }

        return next.process(request)
    }

    @available(iOS 13.0, *)
    open override func make(_ data: EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding>) -> PublisherContext<Type> {
        Just(data)
            .tryMap(self.transform)
            .flatMap(self.next.make)
            .asContext()
    }

    open func transform(data: EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding>) throws -> TransportUrlRequest {
        var url: URL

        url = try data.route.url()

        let params = TransportUrlParameters(method: self.method,
                                            url: url,
                                            headers: data.metadata,
                                            parametersEncoding: data.encoding)

        return TransportUrlRequest(with: params, raw: data.raw)
    }
}
