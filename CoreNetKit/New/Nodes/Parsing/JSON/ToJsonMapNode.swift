//
//  ToJsonMapNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 09/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation
import ObjectMapper

/// Node that provide possibility to map Object to JSON with ObjectMapper
open class ToJsonMapNode<Input: Mappable>: Node<Input, CoreNetKitJson> {
    open override func process(_ data: Input) -> Context<CoreNetKitJson> {
        let result = Context<CoreNetKitJson>()
        result.emit(data: data.toJSON())
        return result
    }
}
