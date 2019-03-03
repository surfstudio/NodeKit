//
//  AccessSafeNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 22/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

class AccessSafeNode: TransportLayerNode {
    var tokenProvider: () -> String

    var tokenConnectorNode: TransportLayerNode
    var markerNode: MarkerNode<TransportUrlRequest>
    var items: [TransportUrlRequest]
    var tokenUpdateChain: Node<EmptyModel, EmptyModel>

    init(tokenProvider: @escaping () -> String,
         tokenConnectorNode: TransportLayerNode,
         markerNode: MarkerNode<TransportUrlRequest>,
         tokenUpdateChain: Node<EmptyModel, EmptyModel>) {
        self.tokenProvider = tokenProvider
        self.tokenConnectorNode = tokenConnectorNode
        self.items = [TransportUrlRequest]()
        self.markerNode = markerNode
        self.tokenUpdateChain = tokenUpdateChain
    }

    override func process(_ data: TransportUrlRequest) -> Observer<Json> {

        return self.getMark(with: data)
            .map { Mark(model: data, mark: $0) }
            .flatMap { self.markerNode.process($0) }
            .map { item in
                let index = item.mark
                DispatchQueue.global(qos: .userInitiated).async(flags: .barrier, execute: {
                    self.items.remove(at: index)
                })
                return item.model
            }.onError { error in
                if case ResponseHttpErrorProcessorNodeError.unauthorized = error {
                    self.tokenUpdateChain.process().onCompleted {_ in
                        self.sendRequests()
                    }.onError { error in
                        // In This case we cant renew token and pplication should do something with it
                    }
                }
            }.map { $0 }
    }

    func getMark(with data: TransportUrlRequest) -> Context<Int> {

        let context = Context<Int>()

        DispatchQueue.global(qos: .userInitiated).async(flags: .barrier, execute: {
            self.items.append(data)
            context.emit(data: self.items.count)
        })

        return context
    }

    func sendRequests() {
        
    }
}
