//
//  Pager.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 10/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol Paginable {
    func next() -> Self
}

open class OffsetPager<Input, Output>: Observer<Output>, Paginable {

    // MARK: - Types

    public typealias PagingNode = Node<Input, Output> & Paginable

    // MARK: - Fields

    public var onOverClosure: (() -> Void)?

    // MARK: - Properties

    public var pagingNode: PagingNode

    // MARK: - Init and deinit

    public init(pagingNode: PagingNode) {
        self.pagingNode = pagingNode
        super.init()
    }

    // MARK: - Subscription

    open func onOver(_ closure: @escaping () -> Void) -> Self {
        self.onOverClosure = closure
        return self
    }

    // MARK: - Methods

    @discardableResult
    open func next() -> Self {
        _ = self.pagingNode.next()
        return self
    }
}
