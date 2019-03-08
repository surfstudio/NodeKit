//
//  ChainConfiguratorNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 08/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

open class ChainConfiguratorNode<I, O>: Node<I, O> {

    public var next: Node<I, O>

    public init(next: Node<I, O>) {
        self.next = next
    }

    open override func process(_ data: I) -> Observer<O> {
        return Context<Void>.emit(data: ())
            .dispatchOn(.global(qos: .userInitiated))
            .flatMap { return self.next.process(data) }
            .dispatchOn(.main)
    }
}
