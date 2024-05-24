import Foundation

/// Этот узел переводит Generic запрос в конкретную реализацию.
/// Данный узел работает с URL-запросами, по HTTP протоколу с JSON
open class URLRequestTrasformatorNode<Type>: AsyncNode {

    /// Следйющий узел для обработки.
    public var next: any AsyncNode<RequestEncodingModel, Type>

    /// HTTP метод для запроса.
    public var method: Method

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следйющий узел для обработки.
    ///   - method: HTTP метод для запроса.
    public init(next: some AsyncNode<RequestEncodingModel, Type>, method: Method) {
        self.next = next
        self.method = method
    }

    /// Конструирует модель для для работы на транспортном уровне цепочки.
    ///
    /// - Parameter data: Данные для дальнейшей обработки.
    open func process(
        _ data: EncodableRequestModel<URLRouteProvider, Json, ParametersEncoding?>,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Type> {
        await .withMappedExceptions {
            .success(try data.route.url())
        }
        .asyncFlatMap { url in
            await .withCheckedCancellation {
                let params = TransportURLParameters(
                    method: method,
                    url: url,
                    headers: data.metadata
                )
                let encodingModel = RequestEncodingModel(
                    urlParameters: params,
                    raw: data.raw,
                    encoding: data.encoding ?? nil
                )
                return await next.process(encodingModel, logContext: logContext)
            }
        }
    }
}
