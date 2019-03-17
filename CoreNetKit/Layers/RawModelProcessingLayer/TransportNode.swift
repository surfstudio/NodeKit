//
//  TransportNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

/// Словарь вида `[String: Any]`
public typealias Json = [String: Any]

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
