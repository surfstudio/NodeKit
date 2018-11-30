//
//  TrasportNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import ObjectMapper

class RequestModel<Model> {
    let model: Model
    let method: Method
    let url: URL
    var headers: [String: String]

    init(model: Model, method: Method, url: URL, headers: [String: String] = [:]) {
        self.model = model
        self.method = method
        self.url = url
        self.headers = headers
    }

    func map<T>(with model: T) -> RequestModel<T> {
        return RequestModel<T>(
            model: model,
            method: self.method,
            url: self.url,
            headers: self.headers
        )
    }
}

class TrasportNode<Input: Mappable, Output: Mappable>: Node<RequestModel<Input>, Output> {

    var toJsonMapNode: Node<Input, CoreNetKitJson>
    var fromJsonMapNode: Node<CoreNetKitJson, Output>
    var nextNode: Node<RequestModel<CoreNetKitJson>, CoreNetKitJson>

    init(toJsonMapNode: Node<Input, CoreNetKitJson>, fromJsonMapNode: Node<CoreNetKitJson, Output>, nextNode: Node<RequestModel<CoreNetKitJson>, CoreNetKitJson>) {
        self.toJsonMapNode = toJsonMapNode
        self.fromJsonMapNode = fromJsonMapNode
        self.nextNode = nextNode
    }

    override func input(_ data: RequestModel<Input>) -> Context<Output> {
        return self.toJsonMapNode.input(data.model)
            .flatMap { self.nextNode.input(data.map(with: $0)) }
            .flatMap { self.fromJsonMapNode.input($0) }
    }
}
