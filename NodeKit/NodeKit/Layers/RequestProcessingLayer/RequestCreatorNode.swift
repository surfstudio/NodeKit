import Foundation

/// Этот узел инициаллизирует URL запрос.
open class RequestCreatorNode<Output>: AsyncNode {

    /// Следующий узел для обработки.
    public var next: any AsyncNode<URLRequest, Output>

    /// Провайдеры мета-данных
    public var providers: [MetadataProvider]

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: some AsyncNode<URLRequest, Output>, providers: [MetadataProvider] = []) {
        self.next = next
        self.providers = providers
    }

    /// Конфигурирует низкоуровневый запрос.
    ///
    /// - Parameter data: Данные для конфигурирования и последующей отправки запроса.
    open func process(
        _ data: TransportURLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        var mergedHeaders = data.headers

        providers.map { $0.metadata() }.forEach { dict in
            mergedHeaders.merge(dict, uniquingKeysWith: { $1 })
        }

        var request = URLRequest(url: data.url)
        request.httpMethod = data.method.rawValue
        request.httpBody = data.raw
        mergedHeaders.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        await logContext.add(getLogMessage(data))
        return await next.process(request, logContext: logContext)
    }

    private func getLogMessage(_ data: TransportURLRequest) -> Log {
        var message = "<<<===\(self.objectName)===>>>\n"
        message += "input: \(type(of: data))\n\t"
        message += "method: \(data.method.rawValue)\n\t"
        message += "url: \(data.url.absoluteString)\n\t"
        message += "headers: \(data.headers)\n\t"
        message += "raw: \(String(describing: data.raw))\n\t"

        return Log(message, id: self.objectName, order: LogOrder.requestCreatorNode)
    }
}
