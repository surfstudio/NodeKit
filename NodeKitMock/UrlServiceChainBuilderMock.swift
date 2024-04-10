//
//  UrlServiceChainBuilderMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public class UrlServiceChainBuilderMock: UrlServiceChainBuilder {
    
    /// Создает цепочку узлов, описывающих транспортный слой обработки.
    override public func requestTrasportChain(providers: [MetadataProvider], session: URLSession?) -> any TransportLayerNode {
        let requestSenderNode = RequestSenderNode(
            rawResponseProcessor: self.urlResponseProcessingLayerChain(),
            manager: NetworkMock().urlSession
        )
        let technicalErrorMapperNode = TechnicaErrorMapperNode(next: requestSenderNode)
        return RequestCreatorNode(next: technicalErrorMapperNode, providers: providers)
    }
    
}
