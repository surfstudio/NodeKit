//
//  UrlBsonServiceChainBuilder.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 17.06.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//
import Foundation
import NodeKit

/// Умеет создавать цепочки
open class UrlBsonServiceChainBuilder {

    /// Конструктор по-умолчанию.
    public init() { }

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

}
