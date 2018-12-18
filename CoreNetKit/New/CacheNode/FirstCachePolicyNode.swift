//
//  CachePreprocessor.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

public enum BaseFirstCachePolicyNodeError: Error {
    case cantGetUrlRequest
}

open class FirstCachePolicyNode: Node<RawUrlRequest, CoreNetKitJson> {

    public typealias CacheReaderNode = Node<UrlNetworkRequest, CoreNetKitJson>
    public typealias NextProcessorNode = Node<RawUrlRequest, CoreNetKitJson>

    private let cacheReaderNode: CacheReaderNode
    private let next: Node<RawUrlRequest, CoreNetKitJson>

    public init(cacheReaderNode: CacheReaderNode, next: NextProcessorNode) {
        self.cacheReaderNode = cacheReaderNode
        self.next = next
    }

    open override func process(_ data: RawUrlRequest) -> Context<CoreNetKitJson> {
        let result = Context<CoreNetKitJson>()

        if let urlRequest = data.toUrlRequest() {
            self.cacheReaderNode.process(urlRequest)
                .onCompleted { result.emit(data: $0) }
                .onError { result.emit(error: $0) }
        } else  {
            result.emit(error: BaseFirstCachePolicyNodeError.cantGetUrlRequest)
        }

        next.process(data)
            .onCompleted { result.emit(data: $0)}
            .onError { result.emit(error: $0) }

        return result
    }
}

// First Cahce then refresh from server
// JsonNEtworkNode -> RawRequestPostprocessor -> CachePolicy -> NetworkResponseProcessor
// First server - if - fails - from cache
// JsonNEtworkNode -> RawRequestPostprocessor -> NetworkResponseProcessor -> CacheProcessor
