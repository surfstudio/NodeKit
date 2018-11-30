//
//  ServiceChains.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import ObjectMapper

class ServiceChains {
    static func JsonRequestChain<Input: Mappable, Output: Mappable>(model: Input) -> JsonRequest<Input, Output> {

        let rawResponseProcessor = RawJsonResponseProcessor()
        let requestSenderNode = JsonNetworkReqestSenderNode(rawResponseProcessor: rawResponseProcessor)
        let networkNode = JsonNetworkNode(next: requestSenderNode)
        let preprocessingNode = HeaderAttacher(next: networkNode)
        let toJson = ToJsonMapNode<Input>()
        let fromJson = FromJsonMapNode<Output>()

        let transport = TrasportNode<Input, Output>(toJsonMapNode: toJson, fromJsonMapNode: fromJson, nextNode: preprocessingNode)

        return JsonRequest<Input, Output>(with: model, root: transport)
    }

    static func JsonRequestChainFirstCacheChain<Input: Mappable, Output: Mappable>(model: Input) -> JsonRequest<Input, Output> {
        let cacheWriter = UrlCacheWriterNode()
        let rawResponseProcessor = RawJsonResponseProcessor(next: cacheWriter)
        let requestSenderNode = JsonNetworkReqestSenderNode(rawResponseProcessor: rawResponseProcessor)
        let cacheNode = FirstCachePolicyNode(cacheReaderNode: UrlCacheReaderNode(), next: requestSenderNode)
        let networkNode = JsonNetworkNode(next: cacheNode)
        let preprocessingNode = HeaderAttacher(next: networkNode)
        let toJson = ToJsonMapNode<Input>()
        let fromJson = FromJsonMapNode<Output>()

        let transport = TrasportNode<Input, Output>(toJsonMapNode: toJson, fromJsonMapNode: fromJson, nextNode: preprocessingNode)

        return JsonRequest<Input, Output>(with: model, root: transport)
    }
}
