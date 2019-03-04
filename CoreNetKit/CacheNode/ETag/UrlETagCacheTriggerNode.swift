//
//  ETagRederNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

open class UrlETagUrlCacheTriggerNode: ResponseProcessingLayerNode {

    public var next: ResponseProcessingLayerNode
    public var cacheReader: Node<UrlNetworkRequest, Json>
    public var eTagHeaderKey: String

    public init(next: ResponseProcessingLayerNode,
                cacheReader: Node<UrlNetworkRequest, Json>,
                eTagHeaderKey: String = ETagConstants.eTagResponseHeaderKey) {
        self.next = next
        self.eTagHeaderKey = eTagHeaderKey
        self.cacheReader = cacheReader
    }

    open override func process(_ data: UrlDataResponse) -> Observer<Json> {
        guard data.response.statusCode == 304 else {
            return next.process(data)
        }

        return cacheReader.process(UrlNetworkRequest(urlRequest: data.request))
    }
}
