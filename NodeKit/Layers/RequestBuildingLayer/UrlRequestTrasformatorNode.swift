import Foundation
import Alamofire

enum RequestEncodingError: Error {
    case unsupportedDataType
}

/// Этот узел переводит Generic запрос в конкретную реализацию.
/// Данный узел работает с URL-запросами, по HTTP протоколу с JSON
open class UrlRequestTrasformatorNode<Raw, Type>: Node<EncodableRequestModel<UrlRouteProvider, Raw, ParametersEncoding>, Type> {

    /// Следйющий узел для обработки.
    public var next: Node<RequestEncodingModel<Raw>, Type>

    /// HTTP метод для запроса.
    public var method: Method

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следйющий узел для обработки.
    ///   - method: HTTP метод для запроса.
    public init(next: Node<RequestEncodingModel<Raw>, Type>, method: Method) {
        self.next = next
        self.method = method
    }

    /// Конструирует модель для для работы на транспортном уровне цепочки.
    ///
    /// - Parameter data: Данные для дальнейшей обработки.
    open override func process(_ data: EncodableRequestModel<UrlRouteProvider, Raw, ParametersEncoding>) -> Observer<Type> {

        var url: URL

        do {
            url = try data.route.url()
        } catch {
            return .emit(error: error)
        }

        let params = TransportUrlParameters(method: self.method,
                                            url: url,
                                            headers: data.metadata)

        let encodingModel = RequestEncodingModel(urlParameters: params,
                                                 raw: data.raw,
                                                 encoding: data.encoding)
        return next.process(encodingModel)
    }

}
