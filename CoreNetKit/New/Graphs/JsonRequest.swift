//
//  RequestNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import ObjectMapper

public enum BaseJsonRequestError: Error {
    case urlNotSet
}

open class JsonRequest<Input: Mappable, Output: Mappable> {

    public typealias Model = Input

    private let requestModel: Input

    private let root: Node<RequestModel<Input>, Output>
    private var method = Method.get
    private var url: URL?

    public init(with model: Input, root: Node<RequestModel<Input>, Output>) {
        self.requestModel = model
        self.root = root
    }

    open func start() -> Context<Output> {

        guard let url = self.url else {
            let result = Context<Output>()
            result.emit(error: BaseJsonRequestError.urlNotSet)
            return result
        }

        return self.root.process(RequestModel<Input>(model: self.requestModel, method: self.method, url: url))
    }

    open func encoding(with method: Method) -> Self {
        self.method = method
        return self
    }

    open func set(url: URL) -> Self {
        self.url = url
        return self
    }
 }
