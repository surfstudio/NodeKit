//
//  UrlRequestTrasformatorNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

open class UrlRequestTrasformatorNode: Node<EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding>, Json> {

    public var next: TransportLayerNode
    public var method: Method

    public init(next: TransportLayerNode, method: Method) {
        self.next = next
        self.method = method
    }

    open override func process(_ data: EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding>) -> Observer<Json> {

        var url: URL

        do {
            url = try data.route.url()
        } catch {
            return .emit(error: error)
        }

        let params = TransportUrlParameters(method: self.method,
                                            url: url,
                                            headers: data.metadata,
                                            parametersEncoding: data.encoding)

        let request = TransportUrlRequest(with: params, raw: data.raw)

        return next.process(request)
    }
}
