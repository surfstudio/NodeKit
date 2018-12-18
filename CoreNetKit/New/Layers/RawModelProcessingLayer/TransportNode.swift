//
//  TransportNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

public typealias Json = [String: String]

public enum Method {
    case get
    case post
    case put
    case delete
}

public struct TransportUrlParameters {
    let method: Method
    let url: URL
    let headers: [String: String]
}

public struct TransportUrlRequest {
    let method: Method
    let url: URL
    let headers: [String: String]
    let raw: Json

    init(with params: TransportUrlParameters, raw: Json) {
        self.method = params.method
        self.url = params.url
        self.headers = params.headers
        self.raw = raw
    }
}

open class TrasnportNode: Node<Json, Json> {

    public var next: Node<TransportUrlRequest, Json>
    public var parameters: TransportUrlParameters

    public init(parameters: TransportUrlParameters, next: Node<TransportUrlRequest, Output>) {
        self.next = next
        self.parameters = parameters
    }

    open override func process(_ data: Json) -> Context<Json> {
        return next.process(TransportUrlRequest(with: self.parameters, raw: data))
    }
}
