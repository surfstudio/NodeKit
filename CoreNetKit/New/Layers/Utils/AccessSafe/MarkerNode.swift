//
//  MarkerNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 25/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

struct Mark<T> {
    var model: T
    var mark: Int
}

class MarkerNode<T>: Node<Mark<T>, Mark<Json>> {

    var next: Node<T, Json>

    init(next: Node<T, Json>) {
        self.next = next
    }

    override func process(_ data: Mark<T>) -> Context<Mark<Json>> {
        return next.process(data.model).map { Mark(model: $0, mark: data.mark) }
    }
}
