//
//  EtagReaderNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

open class UrlETagReaderNode: TransportLayerNode {

    public var next: TransportLayerNode
    public var etagHeaderKey: String

    public init(next: TransportLayerNode,
                etagHeaderKey: String = ETagConstants.eTagRequestHeaderKey) {
        self.next = next
        self.etagHeaderKey = etagHeaderKey
    }

    open override func process(_ data: TransportUrlRequest) -> Observer<Json> {
        guard let tag = UserDefaults.etagStorage?.value(forKey: data.url.absoluteString) as? String else {
            return next.process(data)
        }

        var headers = data.headers
        headers[self.etagHeaderKey] = tag

        let params = TransportUrlParameters(method: data.method,
                                            url: data.url,
                                            headers: headers,
                                            parametersEncoding: data.parametersEncoding)

        let newData = TransportUrlRequest(with: params, raw: data.raw)

        return next.process(newData)
    }
}
