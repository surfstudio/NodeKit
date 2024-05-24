//
//  ServiceChainProvider.swift
//  NodeKit
//
//  Created by Andrei Frolov on 02.05.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

public protocol ServiceChainProvider {
    func provideRequestJsonChain(
        with providers: [MetadataProvider]
    ) -> any AsyncNode<TransportURLRequest, Json>
    
    func provideRequestDataChain(
        with providers: [MetadataProvider]
    ) -> any AsyncNode<TransportURLRequest, Data>
    
    func provideRequestMultipartChain() -> any AsyncNode<MultipartURLRequest, Json>
}

open class URLServiceChainProvider: ServiceChainProvider {

    // MARK: - Public Properties
    
    public let session: URLSession?
    
    // MARK: - Initialization
    
    public init(session: URLSession? = nil) {
        self.session = session
    }
    
    // MARK: - ServiceChainProvider
    
    /// Цепочка обработки Json ответа от сервера.
    open func provideResponseJsonChain() -> any AsyncNode<NodeDataResponse, Json> {
        let responseDataParserNode = ResponseDataParserNode()
        let responseDataPreprocessorNode = ResponseDataPreprocessorNode(next: responseDataParserNode)
        let responseHttpErrorProcessorNode = ResponseHttpErrorProcessorNode(next: responseDataPreprocessorNode)
        return ResponseProcessorNode(next: responseHttpErrorProcessorNode)
    }
    
    /// Цепочка создания и отправки запроса, ожидающая Json ответ.
    ///
    /// - Parameter providers: Массив провайдеров, предоставляющих метаданные, которые будут включены в запрос.
    open func provideRequestJsonChain(
        with providers: [MetadataProvider]
    ) -> any AsyncNode<TransportURLRequest, Json> {
        let requestSenderNode = RequestSenderNode(
            rawResponseProcessor: provideResponseJsonChain(),
            manager: session
        )
        let technicalErrorMapperNode = TechnicaErrorMapperNode(next: requestSenderNode)
        let aborterNode = AborterNode(next: technicalErrorMapperNode, aborter: requestSenderNode)
        return RequestCreatorNode(next: aborterNode, providers: providers)
    }
    
    /// Цепочка обработки Data ответа от сервера.
    open func provideResponseDataChain() -> any AsyncNode<NodeDataResponse, Data> {
        let loaderParser = DataLoadingResponseProcessor()
        let errorProcessor = ResponseHttpErrorProcessorNode(next: loaderParser)
        return ResponseProcessorNode(next: errorProcessor)
    }
    
    /// Цепочка создания и отправки запроса, ожидающая Data ответ.
    ///
    /// - Parameter providers: Массив провайдеров, предоставляющих метаданные, которые будут включены в запрос.
    open func provideRequestDataChain(
        with providers: [MetadataProvider]
    ) -> any AsyncNode<TransportURLRequest, Data> {
        let requestSenderNode = RequestSenderNode(
            rawResponseProcessor: provideResponseDataChain(),
            manager: session
        )
        let aborterNode = AborterNode(next: requestSenderNode, aborter: requestSenderNode)
        return RequestCreatorNode(next: aborterNode, providers: providers)
    }
    
    /// Цепочка обработки Multipart ответа от сервера.
    open func provideResponseMultipartChain() -> any AsyncNode<NodeDataResponse, Json> {
        let responseDataParserNode = ResponseDataParserNode()
        let responseDataPreprocessorNode = ResponseDataPreprocessorNode(next: responseDataParserNode)
        let responseHttpErrorProcessorNode = ResponseHttpErrorProcessorNode(next: responseDataPreprocessorNode)
        return ResponseProcessorNode(next: responseHttpErrorProcessorNode)
    }
    
    /// Цепочка создания и отправки запроса, ожидающая Multipart ответ.
    open func provideRequestMultipartChain() -> any AsyncNode<MultipartURLRequest, Json> {
        let responseChain = provideResponseMultipartChain()
        let requestSenderNode = RequestSenderNode(
            rawResponseProcessor: responseChain,
            manager: session
        )
        let aborterNode = AborterNode(next: requestSenderNode, aborter: requestSenderNode)
        return MultipartRequestCreatorNode(next: aborterNode)
    }
}
