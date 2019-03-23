//
//  TechnicaErrorMapperNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 12/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public enum BaseTechnicalError: Error {
    case noInternetConnection
    case timeout
    case cantConnectToHost
}

open class TechnicaErrorMapperNode: TransportLayerNode {

    open var next: TransportLayerNode

    public init(next: TransportLayerNode) {
        self.next = next
    }

    open override func process(_ data: TransportUrlRequest) -> Context<Json> {
        let context = Context<Json>()

        self.next.process(data)
            .onCompleted { context.emit(data: $0) }
            .onError { error in
                switch (error as NSError).code {
                case -1009:
                    context.emit(error: BaseTechnicalError.noInternetConnection)
                case -1001:
                    context.emit(error: BaseTechnicalError.timeout)
                case -1004:
                    context.emit(error: BaseTechnicalError.cantConnectToHost)
                default:
                    context.emit(error: error)
                }
            }

        return context
    }
}

