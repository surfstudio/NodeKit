//
//  TrasportNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import ObjectMapper

open class RequestModel<Model> {
    public let model: Model
    public let method: Method
    public let url: URL
    open var headers: [String: String]

    public init(model: Model, method: Method, url: URL, headers: [String: String] = [:]) {
        self.model = model
        self.method = method
        self.url = url
        self.headers = headers
    }

    open func map<T>(with model: T) -> RequestModel<T> {
        return RequestModel<T>(
            model: model,
            method: self.method,
            url: self.url,
            headers: self.headers
        )
    }
}

open class RootTransportNode<Input: Mappable, Output: Mappable>: Node<RequestModel<Input>, Output> {

    open var toJsonMapNode: Node<Input, CoreNetKitJson>
    open var fromJsonMapNode: Node<CoreNetKitJson, Output>
    open var nextNode: Node<RequestModel<CoreNetKitJson>, CoreNetKitJson>

    public init(toJsonMapNode: Node<Input, CoreNetKitJson>, fromJsonMapNode: Node<CoreNetKitJson, Output>, nextNode: Node<RequestModel<CoreNetKitJson>, CoreNetKitJson>) {
        self.toJsonMapNode = toJsonMapNode
        self.fromJsonMapNode = fromJsonMapNode
        self.nextNode = nextNode
    }

    open override func process(_ data: RequestModel<Input>) -> Context<Output> {
        return self.toJsonMapNode.process(data.model)
            .flatMap { self.nextNode.process(data.map(with: $0)) }
            .flatMap { self.fromJsonMapNode.process($0) }
    }
}
