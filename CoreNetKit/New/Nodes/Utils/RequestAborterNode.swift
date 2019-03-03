//
//  RequestAborterNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 03/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol Aborter {
    func cancel()
}

open class AborterNode<Input, Output>: Node<Input, Output> {
    public var next: Node<Input, Output>
    public var aborter: Aborter

    init(next: Node<Input, Output>, aborter: Aborter) {
        self.next = next
        self.aborter = aborter
    }

    open override func process(_ data: Input) -> Observer<Output> {
        return self.next.process(data)
            .multicast()
            .onCanceled {
                self.aborter.cancel()
            }
    }
}
