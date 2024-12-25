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
    
    func provideRequestMultipartChain(
        with providers: [MetadataProvider]
    ) -> any AsyncNode<MultipartURLRequest, Json>
}

open class URLServiceChainProvider: ServiceChainProvider {

    // MARK: - Public Properties
    
    public let session: URLSession?
    
    // MARK: - Initialization
    
    public init(session: URLSession? = nil) {
        self.session = session
    }
    
    // MARK: - ServiceChainProvider
    
    /// Chain for processing ``Json`` response from the server.
    open func provideResponseJsonChain() -> any AsyncNode<NodeDataResponse, Json> {
        let responseDataParserNode = ResponseDataParserNode()
        let responseDataPreprocessorNode = ResponseDataPreprocessorNode(next: responseDataParserNode)
        let responseHttpErrorProcessorNode = ResponseHttpErrorProcessorNode(next: responseDataPreprocessorNode)
        return ResponseProcessorNode(next: responseHttpErrorProcessorNode)
    }
    
    /// Chain for creating and sending a request, expecting a ``Json`` response.
    ///
    /// - Parameter providers: Providing metadata to be included in the request.
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
    
    /// Chain for processing the server's Data response.
    open func provideResponseDataChain() -> any AsyncNode<NodeDataResponse, Data> {
        let loaderParser = DataLoadingResponseProcessor()
        let errorProcessor = ResponseHttpErrorProcessorNode(next: loaderParser)
        return ResponseProcessorNode(next: errorProcessor)
    }
    
    /// Chain for creating and sending a request, expecting a Data response.
    ///
    /// - Parameter providers: Providing metadata to be included in the request.
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
    
    /// Chain for processing a Multipart response from the server.
    open func provideResponseMultipartChain() -> any AsyncNode<NodeDataResponse, Json> {
        let responseDataParserNode = ResponseDataParserNode()
        let responseDataPreprocessorNode = ResponseDataPreprocessorNode(next: responseDataParserNode)
        let responseHttpErrorProcessorNode = ResponseHttpErrorProcessorNode(next: responseDataPreprocessorNode)
        return ResponseProcessorNode(next: responseHttpErrorProcessorNode)
    }
    
    /// Chain for creating and sending a request, expecting a Multipart response.
    open func provideRequestMultipartChain(
        with providers: [MetadataProvider]
    ) -> any AsyncNode<MultipartURLRequest, Json> {
        let responseChain = provideResponseMultipartChain()
        let requestSenderNode = RequestSenderNode(
            rawResponseProcessor: responseChain,
            manager: session
        )
        let aborterNode = AborterNode(next: requestSenderNode, aborter: requestSenderNode)
        return MultipartRequestCreatorNode(next: aborterNode, providers: providers)
    }
}
