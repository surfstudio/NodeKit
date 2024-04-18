import Foundation

/// Задача этого узла добавить метаданные к создаваемому запросу
/// Инициаллизирует цепочку сборки HTTP - запроса.
/// - SeeAlso:
///     - `RequestModel`
///     - `Node`
///     - `RequestRouterNode`
open class MetadataConnectorNode<Raw, Output>: AsyncNode {

    /// Следующий в цепочке узел.
    public var next: any AsyncNode<RequestModel<Raw>, Output>

    /// Метаданные для запроса
    public var metadata: [String: String]

    /// Инициаллизирует узел
    ///
    /// - Parameters:
    ///   - next: Следующий в цепочке узел.
    ///   - metadata: Метаданные для запроса.
    public init(next: some AsyncNode<RequestModel<Raw>, Output>, metadata: [String: String]) {
        self.next = next
        self.metadata = metadata
    }

    /// формирует модель `RequestModel` и передает ее на дальнейшую обработку.
    ///
    /// - Parameter data: данные в Raw формате. (после маппинга из Entry)
    open func process(
        _ data: Raw,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await .withCheckedCancellation {
            await next.process(
                RequestModel(metadata: metadata, raw: data),
                logContext: logContext
            )
        }
    }
}
