//
//  RequestNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import ObjectMapper

enum Method {
    case get
    case post
    case put
    case delete
}

enum BaseJsonRequestError: Error {
    case urlNotSet
}

class JsonRequest<Input: Mappable, Output: Mappable> {

    typealias Model = Input

    private let requestModel: Input

    private let root: Node<RequestModel<Input>, Output>
    private var method = Method.get
    private var url: URL?

    init(with model: Input, root: Node<RequestModel<Input>, Output>) {
        self.requestModel = model
        self.root = root
    }

    func start() -> Context<Output> {

        guard let url = self.url else {
            let result = Context<Output>()
            result.emit(error: BaseJsonRequestError.urlNotSet)
            return result
        }

        return self.root.input(RequestModel<Input>(model: self.requestModel, method: self.method, url: url))
    }

    func encoding(with method: Method) -> Self {
        self.method = method
        return self
    }

    func set(url: URL) -> Self {
        self.url = url
        return self
    }
 }
