import Foundation

/// Этот узел переводит Generic запрос в конкретную реализацию.
/// Данный узел работает с URL-запросами, по HTTP протоколу с JSON
open class MultipartUrlRequestTrasformatorNode<Type>: AsyncNode {

    /// Следйющий узел для обработки.
    open var next: any AsyncNode<MultipartUrlRequest, Type>

    /// HTTP метод для запроса.
    open var method: Method

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следйющий узел для обработки.
    ///   - method: HTTP метод для запроса.
    public init(next: any AsyncNode<MultipartUrlRequest, Type>, method: Method) {
        self.next = next
        self.method = method
    }

    /// Конструирует модель для для работы на транспортном уровне цепочки.
    ///
    /// - Parameter data: Данные для дальнейшей обработки.
    open func process(
        _ data: RoutableRequestModel<UrlRouteProvider, MultipartModel<[String : Data]>>
    ) -> Observer<Type> {

        var url: URL

        do {
            url = try data.route.url()
        } catch {
            return .emit(error: error)
        }


        let request = MultipartUrlRequest(method: self.method,
                                          url: url,
                                          headers: data.metadata,
                                          data: data.raw)

        return next.process(request)
    }

    /// Конструирует модель для для работы на транспортном уровне цепочки.
    ///
    /// - Parameter data: Данные для дальнейшей обработки.
    open func process(
        _ data: RoutableRequestModel<UrlRouteProvider, MultipartModel<[String : Data]>>,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Type> {
        return await .withMappedExceptions {
            let url = try data.route.url()
            let request = MultipartUrlRequest(
                method: method,
                url: url,
                headers: data.metadata,
                data: data.raw
            )
            return await next.process(request, logContext: logContext)
        }
    }
}
