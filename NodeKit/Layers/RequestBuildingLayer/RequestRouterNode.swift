import Foundation
import Combine

/// Этот узел добавляет маршрут к создаваемому запросу.
/// - SeeAlso:
///     - `RequestModel`
///     - `RoutableRequestModel`
///     - `Node`
///     - `MetadataConnectorNode`
///     - `RequstEncoderNode`
open class RequestRouterNode<Raw, Route, Output>: Node<RequestModel<Raw>, Output> {

    /// Тип для следующего узла.
    public typealias NextNode = Node<RoutableRequestModel<Route, Raw>, Output>

    /// Следующий узел для обработки.
    public var next: NextNode

    /// Маршрут для запроса.
    public var route: Route

    /// Инициаллизирует узел
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обработки.
    ///   - route: Маршрут для запроса.
    public init(next: NextNode, route: Route) {
        self.next = next
        self.route = route
    }

    /// Преобразует `RequestModel` в `RoutableRequestModel` и передает управление следующему узлу
    open override func process(_ data: RequestModel<Raw>) -> Observer<Output> {
        return self.next.process(RoutableRequestModel(metadata: data.metadata, raw: data.raw, route: self.route))
    }

    @available(iOS 13.0, *)
    open override func make(_ data: RequestModel<Raw>) -> PublisherContext<Output> {
        return self.next.make(.init(metadata: data.metadata, raw: data.raw, route: self.route))
    }
}
