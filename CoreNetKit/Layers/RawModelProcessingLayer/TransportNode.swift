//
//  TransportNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

public typealias Json = [String: Any]

public enum ParametersEncoding {
    case json
    case formUrl
    case urlQuery
}

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
    let parametersEncoding: ParametersEncoding

    public init(method: Method, url: URL, headers: [String: String] = [:], parametersEncoding: ParametersEncoding = .json) {
        self.method = method
        self.url = url
        self.headers = headers
        self.parametersEncoding = parametersEncoding
    }
}

public struct TransportUrlRequest {
    let method: Method
    let url: URL
    let headers: [String: String]
    let raw: Json
    let parametersEncoding: ParametersEncoding

    public init(with params: TransportUrlParameters, raw: Json) {
        self.method = params.method
        self.url = params.url
        self.headers = params.headers
        self.raw = raw
        self.parametersEncoding = params.parametersEncoding
    }
}

open class TransportNode: Node<Json, Json> {

    public var next: TransportLayerNode
    public var parameters: TransportUrlParameters

    public init(parameters: TransportUrlParameters, next: TransportLayerNode) {
        self.next = next
        self.parameters = parameters
    }

    open override func process(_ data: Json) -> Observer<Json> {
        return next.process(TransportUrlRequest(with: self.parameters, raw: data))
    }
}
