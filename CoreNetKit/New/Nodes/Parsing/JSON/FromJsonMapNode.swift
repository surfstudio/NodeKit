//
//  FromJsonMapNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 09/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation
import ObjectMapper

public typealias CoreNetKitJson = [String: Any]

/// Enum for out-of-box mapping errors
public enum BaseMappingError: Error {
    case cantMap
}

/// Node that provide possibility to map JSON to Object with ObjectMapper
open class FromJsonMapNode<Output: Mappable>: Node<CoreNetKitJson, Output> {
    open override func process(_ data: CoreNetKitJson) -> Context<Output> {
        let result = Context<Output>()

        if let mapped = Output(JSON: data) {
            result.emit(data: mapped)
        } else {
            result.emit(error: BaseMappingError.cantMap)
        }
        return result
    }
}
