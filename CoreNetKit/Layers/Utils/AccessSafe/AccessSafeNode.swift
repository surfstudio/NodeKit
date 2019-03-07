//
//  AccessSafeNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 22/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public enum AccessSafeNodeError: Error {
    case nodeWasRelease
}

open class AccessSafeNode: TransportLayerNode {

    public var next: TransportLayerNode
    public var updateTokenChain: Node<Void, Void>

    public init(next: TransportLayerNode, updateTokenChain: Node<Void, Void>) {
        self.next = next
        self.updateTokenChain = updateTokenChain
    }

    override open func process(_ data: TransportUrlRequest) -> Observer<Json> {
        return self.next.process(data).error { error in
            switch error {
            case ResponseHttpErrorProcessorNodeError.forbidden, ResponseHttpErrorProcessorNodeError.unauthorized:
                return self.updateTokenChain.process(()).flatMap { [weak self] _ in

                    guard let `self` = self else {
                        return .emit(error: AccessSafeNodeError.nodeWasRelease)
                    }

                    return self.next.process(data)
                }
            default:
                return .emit(error: error)
            }
        }
    }
}
