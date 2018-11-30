//
//  CachePreprocessor.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

struct RawUrlRequest {
    let dataRequest: DataRequest

    func toUrlRequest() -> UrlNetworkRequest? {

        guard let urlRequest = self.dataRequest.request else {
            return nil
        }

        return UrlNetworkRequest(urlRequest: urlRequest)
    }
}

enum BaseFirstCachePolicyNodeError: Error {
    case cantGetUrlRequest
}

class FirstCachePolicyNode: Node<RawUrlRequest, CoreNetKitJson> {

    typealias CacheReaderNode = Node<UrlNetworkRequest, CoreNetKitJson>
    typealias NextProcessorNode = Node<RawUrlRequest, CoreNetKitJson>

    let cacheReaderNode: CacheReaderNode
    let next: Node<RawUrlRequest, CoreNetKitJson>

    init(cacheReaderNode: CacheReaderNode, next: NextProcessorNode) {
        self.cacheReaderNode = cacheReaderNode
        self.next = next
    }

    override func input(_ data: RawUrlRequest) -> Context<CoreNetKitJson> {
        let result = Context<CoreNetKitJson>()

        if let urlRequest = data.toUrlRequest() {
            self.cacheReaderNode.input(urlRequest)
                .onCompleted { result.emit(data: $0) }
                .onError { result.emit(error: $0) }
        } else  {
            result.emit(error: BaseFirstCachePolicyNodeError.cantGetUrlRequest)
        }

        next.input(data)
            .onCompleted { result.emit(data: $0)}
            .onError { result.emit(error: $0) }

        return result
    }
}

// First Cahce then refresh from server
// JsonNEtworkNode -> RawRequestPostprocessor -> CachePolicy -> NetworkResponseProcessor
// First server - if - fails - from cache
// JsonNEtworkNode -> RawRequestPostprocessor -> NetworkResponseProcessor -> CacheProcessor
