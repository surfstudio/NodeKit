//
//  LoggerNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 07/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

open class LoggerNode<Input, Output>: Node<Input, Output> {
    open var next: Node<Input, Output>
    open var filters: [String]

    public init(next: Node<Input, Output>, filters: [String] = []) {
        self.next = next
        self.filters = filters
    }

    open override func process(_ data: Input) -> Observer<Output> {
        let result = Context<Output>()

        let context = self.next.process(data)

        context.onCompleted { [weak self, context] data in
            self?.log(context.log)
            result.log(context.log).emit(data: data)
        }.onError { [weak self, context] error in
            self?.log(context.log)
            result.log(context.log).emit(error: error)
        }.onCanceled { [weak self, context] in
            self?.log(context.log)
            result.log(context.log).cancel()
        }

        return result
    }

    private func log(_ log: Logable?) {
        guard let log = log else { return }

        log.flatMap().filter { !self.filters.contains($0.id) }.forEach { print($0.description) }
    }
}
