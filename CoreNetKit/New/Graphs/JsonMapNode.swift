//
//  JsonMapNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import ObjectMapper

typealias CoreNetKitJson = [String: Any]

enum BaseMappingError: Error {
    case cantMap
}

class ToJsonMapNode<Input: Mappable>: Node<Input, CoreNetKitJson> {
    override func input(_ data: Input) -> Context<CoreNetKitJson> {
        let result = Context<CoreNetKitJson>()
        result.emit(data: data.toJSON())
        return result
    }
}

class FromJsonMapNode<Output: Mappable>: Node<CoreNetKitJson, Output> {
    override func input(_ data: CoreNetKitJson) -> Context<Output> {
        let result = Context<Output>()

        if let mapped = Output(JSON: data) {
            result.emit(data: mapped)
        } else {
            result.emit(error: BaseMappingError.cantMap)
        }
        return result
    }
}
