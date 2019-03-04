//
//  HeaderInjectorNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Node prvodes possibility to inject any header in request
/// Can used inside transport layer
/// Headers that you add with this node override any existed headers.
/// You should use this node only if you want to provide default headers like locale, device, e.t.c.
open class HeaderInjectorNode: TransportLayerNode {

    public var next: TransportLayerNode
    public var headers: [String: String]

    public init(next: TransportLayerNode, headers: [String: String]) {
        self.next = next
        self.headers = headers
    }

    open override func process(_ data: TransportUrlRequest) -> Observer<Json> {
        var resultHeaders = self.headers
        data.headers.forEach { resultHeaders[$0.key] = $0.value }
        return next.process(data)
    }
}
