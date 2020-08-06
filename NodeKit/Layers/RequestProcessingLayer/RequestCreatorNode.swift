import Foundation

/// Этот узел инициаллизирует URL запрос.
open class RequestCreatorNode<Output>: Node<TransportUrlRequest, Output> {

    /// Следующий узел для обработки.
    public var next: Node<URLRequest, Output>

    /// Провайдеры мета-данных
    public var providers: [MetadataProvider]

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: Node<URLRequest, Output>, providers: [MetadataProvider] = []) {
        self.next = next
        self.providers = providers
    }

    /// Конфигурирует низкоуровненвый запрос.
    ///
    /// - Parameter data: Данные для конфигурирования и последующей отправки запроса.
    open override func process(_ data: TransportUrlRequest) -> Observer<Output> {
        var mergedHeaders = data.headers
        self.providers.map { $0.metadata() }.forEach { dict in
            mergedHeaders.merge(dict, uniquingKeysWith: { $1 })
        }

        var request = URLRequest(url: data.url)
        request.httpMethod = data.method.rawValue
        request.httpBody = data.raw
        mergedHeaders.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        return self.next.process(request).log(self.getLogMessage(data))
    }

    private func getLogMessage(_ data: TransportUrlRequest) -> Log {
        var message = "<<<===\(self.objectName)===>>>\n"
        message += "input: \(type(of: data))\n\t"
        message += "method: \(data.method.rawValue)\n\t"
        message += "url: \(data.url.absoluteString)\n\t"
        message += "headers: \(data.headers)\n\t"
        message += "raw: \(String(describing: data.raw))\n\t"

        return Log(message, id: self.objectName, order: LogOrder.requestCreatorNode)
    }
}
