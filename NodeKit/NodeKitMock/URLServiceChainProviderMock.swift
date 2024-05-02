//
//  URLServiceChainProviderMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

import Foundation

class URLServiceChainProviderMock: URLServiceChainProvider {
    
    override func provideRequestJsonChain(
        with providers: [MetadataProvider]
    ) -> any AsyncNode<TransportURLRequest, Json> {
        let requestSenderNode = RequestSenderNode(
            rawResponseProcessor: provideResponseJsonChain(),
            manager: NetworkMock().urlSession
        )
        let technicalErrorMapperNode = TechnicaErrorMapperNode(next: requestSenderNode)
        return RequestCreatorNode(next: technicalErrorMapperNode, providers: providers)
    }
    
    override func provideRequestDataChain(
        with providers: [MetadataProvider]
    ) -> any AsyncNode<TransportURLRequest, Data> {
        let requestSenderNode = RequestSenderNode(
            rawResponseProcessor: provideResponseDataChain(),
            manager: NetworkMock().urlSession
        )
        let aborterNode = AborterNode(next: requestSenderNode, aborter: requestSenderNode)
        return RequestCreatorNode(next: aborterNode, providers: providers)
    }
    
    override func provideRequestMultipartChain() -> any AsyncNode<URLRequest, Json> {
        let responseChain = provideResponseJsonChain()
        return RequestSenderNode(rawResponseProcessor: responseChain, manager: NetworkMock().urlSession)
    }
}
