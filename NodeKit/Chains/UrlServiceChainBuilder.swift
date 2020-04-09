import Foundation
import Alamofire

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
    open func requestBsonTrasportChain(providers: [MetadataProvider], session: Session?) -> TransportBsonLayerNode {
        let requestSenderNode = RequestSenderNode(rawResponseProcessor: self.urlResponseBsonProcessingLayerChain())
        let technicalErrorMapperNode = TechnicaErrorMapperNode(next: requestSenderNode)
        return BsonRequestCreatorNode(next: technicalErrorMapperNode, providers: providers, session: session)
    }

    /// Создает цепочку узлов, описывающих транспортный слой обработки.
    open func requestTrasportChain(providers: [MetadataProvider], session: Session?) -> TransportLayerNode {
        let requestSenderNode = RequestSenderNode(rawResponseProcessor: self.urlResponseProcessingLayerChain())
        let technicalErrorMapperNode = TechnicaErrorMapperNode(next: requestSenderNode)
        return RequestCreatorNode(next: technicalErrorMapperNode, providers: providers, session: session)
    }

}
