import Foundation
import Alamofire

/// Этот узел инициаллизирует URL запрос.
open class RequestCreatorNode<Output>: Node<TransportUrlRequest, Output> {

    /// Следующий узел для обработки.
    public var next: Node<RawUrlRequest, Output>

    /// Провайдеры мета-данных
    public var providers: [MetadataProvider]

    /// Менеджер сессий
    private(set) var manager: Session

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: Node<RawUrlRequest, Output>, providers: [MetadataProvider] = [], session: Session? = nil) {
        self.next = next
        self.providers = providers
        self.manager = session ?? ServerRequestsManager.shared.manager
    }

    /// Конфигурирует низкоуровненвый запрос.
    ///
    /// - Parameter data: Данные для конфигурирования и последующей отправки запроса.
    open override func process(_ data: TransportUrlRequest) -> Observer<Output> {

        let paramEncoding = {() -> ParameterEncoding in
            if data.method == .get {
                return URLEncoding.default
            }
            return data.parametersEncoding.raw
        }()

        var result = data.headers

        self.providers.map { $0.metadata() }.forEach { dict in
            result.merge(dict, uniquingKeysWith: { $1 })
        }

        let request = manager.request(
            data.url,
            method: data.method.http,
            parameters: data.raw,
            encoding: paramEncoding,
            headers: HTTPHeaders(result)
        )
        return self.next.process(RawUrlRequest(dataRequest: request)).log(self.getLogMessage(data))
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
