import Foundation
import Alamofire

enum RequestEncodingError: Error {
    case unsupportedDataType
}

/// Этот узел переводит Generic запрос в конкретную реализацию.
/// Данный узел работает с URL-запросами, по HTTP протоколу с JSON
open class UrlRequestTrasformatorNode<Raw, Type>: Node<EncodableRequestModel<UrlRouteProvider, Raw, ParametersEncoding>, Type> {

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

        let paramEncoding = { () -> ParameterEncoding in
            guard self.method == .get else {
                return data.encoding.raw
            }
            return URLEncoding.default
        }()

        let request: TransportUrlRequest?

        if let jsonData = data.raw as? Json {
            do {
                request = try paramEncoding.encode(urlParameters: params, parameters: jsonData)
            } catch {
                return .emit(error: error)
            }
        } else if let bsonData = data.raw as? Bson {
            let body = params.method != .get ? bsonData.makeData() : nil
            request = TransportUrlRequest(with: params, raw: body)
        } else {
            request = nil
        }

        guard let unwrappedRequest = request else {
            return .emit(error: RequestEncodingError.unsupportedDataType)
        }

        return next.process(unwrappedRequest)
    }
}
