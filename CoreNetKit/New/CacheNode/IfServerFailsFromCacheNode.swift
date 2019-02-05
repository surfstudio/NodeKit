//
//  IfServerFailsFromCacheNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

open class IfServerFailedFromCacheNode: ResponseProcessingLayerNode {

    public var next: ResponseProcessingLayerNode
    public var cacheReaderNode: Node<UrlDataResponse, Json>

    public init(next: ResponseProcessingLayerNode, cacheReaderNode: Node<UrlDataResponse, Json>) {
        self.next = next
        self.cacheReaderNode = cacheReaderNode
    }

    open override func process(_ data: UrlDataResponse) -> Context<Json> {
        guard data.response.statusCode != -1009 else {
            return self.cacheReaderNode.process(data)
        }

        return self.next.process(data)
    }

}
