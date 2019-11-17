import Foundation
import Alamofire
import Combine

/// Этот узел инициаллизирует URL запрос.
open class RequestCreatorNode<Output>: Node<TransportUrlRequest, Output> {

    /// Следующий узел для обработки.
    public var next: Node<RawUrlRequest, Output>

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: Node<RawUrlRequest, Output>) {
        self.next = next
    }

    /// Конфигурирует низкоуровненвый запрос.
    ///
    /// - Parameter data: Данные для конфигурирования и последующей отправки запроса.
    open override func process(_ data: TransportUrlRequest) -> Observer<Output> {
        let manager = ServerRequestsManager.shared.manager

        let paramEncoding = {() -> ParameterEncoding in
            if data.method == .get {
                return URLEncoding.default
            }
            return data.parametersEncoding.raw
        }()

        let request = manager.request(
            data.url,
            method: data.method.http,
            parameters: data.raw,
            encoding: paramEncoding,
            headers: HTTPHeaders(data.headers)
        )
        return self.next.process(RawUrlRequest(dataRequest: request)).log(self.getLogMessage(data))
    }

    @available(iOS 13.0, *)
    open override func make(_ data: TransportUrlRequest) -> PublisherContext<Output> {
        let manager = ServerRequestsManager.shared.manager

        let paramEncoding = {() -> ParameterEncoding in
            if data.method == .get {
                return URLEncoding.default
            }
            return data.parametersEncoding.raw
        }()

        let request = manager.request(
            data.url,
            method: data.method.http,
            parameters: data.raw,
            encoding: paramEncoding,
            headers: HTTPHeaders(data.headers)
        )
        return self.next.make(RawUrlRequest(dataRequest: request)).log(self.getLogMessage(data))
    }

    private func getLogMessage(_ data: TransportUrlRequest) -> Log {
        var message = "<<<===\(self.objectName)===>>>\n"
        message += "input: \(type(of: data))\n\t"
        message += "method: \(data.method.http.rawValue)\n\t"
        message += "url: \(data.url.absoluteString)\n\t"
        message += "headers: \(data.headers)\n\t"
        message += "raw: \(data.raw)\n\t"
        message += "parametersEncoding: \(data.parametersEncoding)"

        return Log(message, id: self.objectName, order: LogOrder.requestCreatorNode)
    }
}
