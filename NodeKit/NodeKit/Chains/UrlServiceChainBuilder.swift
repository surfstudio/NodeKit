import Foundation

/// Умеет создавать цепочки 
open class UrlServiceChainBuilder {

    /// Конструктор по-умолчанию.
    public init() { }

    /// Создает цепочку для слоя обработки ответа.
    open func urlResponseProcessingLayerChain() -> any AsyncNode<NodeDataResponse, Json> {
        let responseDataParserNode = ResponseDataParserNode()
        let responseDataPreprocessorNode = ResponseDataPreprocessorNode(next: responseDataParserNode)
        let responseHttpErrorProcessorNode = ResponseHttpErrorProcessorNode(next: responseDataPreprocessorNode)
        return ResponseProcessorNode(next: responseHttpErrorProcessorNode)
    }

    /// Создает цепочку узлов, описывающих транспортный слой обработки.
    open func requestTrasportChain(providers: [MetadataProvider], session: URLSession?) -> any TransportLayerNode {
        let requestSenderNode = RequestSenderNode(
            rawResponseProcessor: self.urlResponseProcessingLayerChain(),
            manager: session
        )
        let technicalErrorMapperNode = TechnicaErrorMapperNode(next: requestSenderNode)
        let aborterNode = AborterNode(next: technicalErrorMapperNode, aborter: requestSenderNode)
        return RequestCreatorNode(next: aborterNode, providers: providers)
    }

}
