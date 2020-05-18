import Foundation

/// Умеет создавать цепочки 
open class UrlServiceChainBuilder {

    /// Конструктор по-умолчанию.
    public init() { }

    /// Создает цепочку для слоя обработки ответа.
    open func urlResponseProcessingLayerChain() -> Node<NodeDataResponse, Json> {
        let responseDataParserNode = ResponseDataParserNode()
        let responseDataPreprocessorNode = ResponseDataPreprocessorNode(next: responseDataParserNode)
        let responseHttpErrorProcessorNode = ResponseHttpErrorProcessorNode(next: responseDataPreprocessorNode)
        return ResponseProcessorNode(next: responseHttpErrorProcessorNode)
    }

    /// Создает цепочку для слоя обработки ответа.
    open func urlResponseBsonProcessingLayerChain() -> Node<NodeDataResponse, Bson> {
        let responseDataParserNode = ResponseBsonDataParserNode()
        let responseDataPreprocessorNode = ResponseBsonDataPreprocessorNode(next: responseDataParserNode)
        let responseHttpErrorProcessorNode = ResponseHttpErrorProcessorNode(next: responseDataPreprocessorNode)
        return ResponseProcessorNode(next: responseHttpErrorProcessorNode)
    }

    /// Создает цепочку узлов, описывающих транспортный слой обработки.
    open func requestBsonTrasportChain(providers: [MetadataProvider], responseQueue: DispatchQueue, session: URLSession?) -> Node<TransportUrlRequest, Bson> {
        let requestSenderNode = RequestSenderNode(rawResponseProcessor: self.urlResponseBsonProcessingLayerChain(),
                                                  responseQueue: responseQueue,
                                                  manager: session)
        let technicalErrorMapperNode = TechnicaErrorMapperNode(next: requestSenderNode)
        return RequestCreatorNode(next: technicalErrorMapperNode, providers: providers)
    }

    /// Создает цепочку узлов, описывающих транспортный слой обработки.
    open func requestTrasportChain(providers: [MetadataProvider], responseQueue: DispatchQueue, session: URLSession?) -> Node<TransportUrlRequest, Json> {
        let requestSenderNode = RequestSenderNode(rawResponseProcessor: self.urlResponseProcessingLayerChain(),
                                                  responseQueue: responseQueue,
                                                  manager: session)
        let technicalErrorMapperNode = TechnicaErrorMapperNode(next: requestSenderNode)
        return RequestCreatorNode(next: technicalErrorMapperNode, providers: providers)
    }

}
