import Foundation
import Combine

/// Этот узел добавляет кодировку к создаваемому запросу.
/// - SeeAlso:
///     - ``
///     - `RequestModel`
///     - `RoutableRequestModel`
///     - `Node`
///     - `RequestRouterNode`
///     - `EncodableRequestModel`
///     - `UrlRequestTrasformatorNode`
open class RequstEncoderNode<Raw, Route, Encoding, Output>: RequestRouterNode<Raw, Route, Output>.NextNode {

    /// Тип для следюущего узла.
    public typealias NextNode = Node<EncodableRequestModel<Route, Raw, Encoding>, Output>

    /// Следюущий узел для обработки.
    public var next: NextNode

    /// Кодировка для запроса.
    public var encoding: Encoding

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следюущий узел для обработки.
    ///   - encoding: Кодировка для запроса.
    public init(next: NextNode, encoding: Encoding) {
        self.next = next
        self.encoding = encoding
    }

    /// Преобразует `RoutableRequestModel` в `EncodableRequestModel`
    /// и передает управление следующему узлу.
    open override func process(_ data: RoutableRequestModel<Route, Raw>) -> Observer<Output> {
        let model = EncodableRequestModel(metadata: data.metadata, raw: data.raw, route: data.route, encoding: self.encoding)
        return self.next.process(model)
    }

    @available(iOS 13.0, *)
    open override func make(_ data: RoutableRequestModel<Route, Raw>) -> PublisherContext<Output> {
        let model = EncodableRequestModel(metadata: data.metadata, raw: data.raw, route: data.route, encoding: self.encoding)
        return self.next.make(model)
    }
}
