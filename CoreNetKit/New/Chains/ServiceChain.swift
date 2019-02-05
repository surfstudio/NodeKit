//
//  SampleChains.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation
import Alamofire

open class ServiceChain {
    public static func urlResponseProcessingLayerChain() -> Node<DataResponse<Data>, Json> {
        let responseDataParserNode = ResponseDataParserNode()
        let responseDataPreprocessorNode = ResponseDataPreprocessorNode(next: responseDataParserNode)
        let responseHttpErrorProcessorNode = ResponseHttpErrorProcessorNode(next: responseDataPreprocessorNode)
        return ResponseProcessorNode(next: responseHttpErrorProcessorNode)
    }

//    public static func urlResponseProcessingLayerChainWithUrlCache(cachePolicy: DefaultCachePolicy) ->
//        Node<DataResponse<Data>, Json> {
//        let urlCacheWriterNode = UrlCacheWriterNode()
//        let urlCacheReaderNode = UrlCacheReaderNode()
//        switch cachePolicy {
//        case .firstCache:
//            let firstCacheNode = FirstCachePolicyNode(cacheReaderNode: urlCacheReaderNode, next: <#T##FirstCachePolicyNode.NextProcessorNode#>)
//        case .ifServerFailsThenCache:
//
//        }
//
//
//        let responseDataParserNode = ResponseDataParserNode(next: urlCacheWriterNode)
//        let responseDataPreprocessorNode = ResponseDataPreprocessorNode(next: responseDataParserNode)
//        let responseHttpErrorProcessorNode = ResponseHttpErrorProcessorNode(next: responseDataPreprocessorNode)
//        return ResponseProcessorNode(next: responseHttpErrorProcessorNode)
//    }
}
