import Foundation

/// Задача этого узла добавить метаданные к создаваемому запросу
/// Инициаллизирует цепочку сборки HTTP - запроса.
/// - SeeAlso:
///     - `RequestModel`
///     - `Node`
///     - `RequestRouterNode`
open class MetadataConnectorNode<Raw, Output>: Node<Raw, Output> {

    /// Следующий в цепочке узел.
    public var next: Node<RequestModel<Raw>, Output>

    /// Метаданные для запроса
    public var metadata: [String: String]

    /// Данные для пагинации в теле запроса
    private var paginationModel: PaginationModel?

    /// Инициаллизирует узел
    ///
    /// - Parameters:
    ///   - next: Следующий в цепочке узел.
    ///   - metadata: Метаданные для запроса.
    public init(next: Node<RequestModel<Raw>, Output>, metadata: [String: String], paginationModel: PaginationModel?) {
        self.next = next
        self.metadata = metadata
        self.paginationModel = paginationModel?.encoding == .json ? paginationModel : nil
    }

    /// формирует модель `RequestModel` и передает ее на дальнейшую обработку.
    ///
    /// - Parameter data: данные в Raw формате. (после маппинга из Entry)
    open override func process(_ data: Raw) -> Observer<Output> {
        guard let params = paginationModel?.parameters, Raw.self == Json.self else {
            return next.process(RequestModel(metadata: self.metadata, raw: data))
        }
        // Дополняем данные тела запроса параметрами пагинации
        var allData: Json = data as! Json
        params.forEach {
            allData[$0] = $1
        }
        return next.process(RequestModel(metadata: self.metadata, raw: allData as! Raw))    }
}
