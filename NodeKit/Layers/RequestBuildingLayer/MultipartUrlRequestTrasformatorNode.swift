import Foundation
import Combine

/// Этот узел переводит Generic запрос в конкретную реализацию.
/// Данный узел работает с URL-запросами, по HTTP протоколу с JSON
open class MultipartUrlRequestTrasformatorNode<Type>: Node<RoutableRequestModel<UrlRouteProvider, MultipartModel<[String : Data]>>, Type> {

    /// Следйющий узел для обработки.
    open var next: Node<MultipartUrlRequest, Type>

    /// HTTP метод для запроса.
    open var method: Method

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следйющий узел для обработки.
    ///   - method: HTTP метод для запроса.
    public init(next: Node<MultipartUrlRequest, Type>, method: Method) {
        self.next = next
        self.method = method
    }

    /// Конструирует модель для для работы на транспортном уровне цепочки.
    ///
    /// - Parameter data: Данные для дальнейшей обработки.
    open override func process(_ data: RoutableRequestModel<UrlRouteProvider, MultipartModel<[String : Data]>>) -> Observer<Type> {

        var request: MultipartUrlRequest

        do {
            request = try self.transform(data: data)
        } catch {
            return .emit(error: error)
        }

        return next.process(request)
    }

    @available(iOS 13.0, *)
    open override func make(_ data: RoutableRequestModel<UrlRouteProvider, MultipartModel<[String : Data]>>) -> PublisherContext<Type> {
        return Just(data)
            .tryMap(self.transform)
            .flatMap(self.next.make)
            .asContext()
    }

    open func transform(data: RoutableRequestModel<UrlRouteProvider, MultipartModel<[String : Data]>>) throws -> MultipartUrlRequest {
        return MultipartUrlRequest(method: self.method,
                                          url: try data.route.url(),
                                          headers: data.metadata,
                                          data: data.raw)
    }
}
