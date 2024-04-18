import Foundation

/// Этот узел переводит Generic запрос в конкретную реализацию.
/// Данный узел работает с URL-запросами, по HTTP протоколу с JSON
open class MultipartURLRequestTrasformatorNode<Type>: AsyncNode {

    /// Следйющий узел для обработки.
    open var next: any AsyncNode<MultipartURLRequest, Type>

    /// HTTP метод для запроса.
    open var method: Method

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следйющий узел для обработки.
    ///   - method: HTTP метод для запроса.
    public init(next: any AsyncNode<MultipartURLRequest, Type>, method: Method) {
        self.next = next
        self.method = method
    }

    /// Конструирует модель для для работы на транспортном уровне цепочки.
    ///
    /// - Parameter data: Данные для дальнейшей обработки.
    open func process(
        _ data: RoutableRequestModel<URLRouteProvider, MultipartModel<[String : Data]>>,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Type> {
        await .withMappedExceptions {
            .success(try data.route.url())
        }
        .asyncFlatMap { url in
            await .withCheckedCancellation {
                let request = MultipartURLRequest(
                    method: method,
                    url: url,
                    headers: data.metadata,
                    data: data.raw
                )
                return await next.process(request, logContext: logContext)
            }
        }
    }
}
