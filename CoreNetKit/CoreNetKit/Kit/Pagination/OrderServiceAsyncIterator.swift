//
//  OrderServiceAsyncIterator.swift
//  GoLamaGo
//
//  Created by Alexander Kravchenkov on 13.09.17.
//  Copyright © 2017 Surf. All rights reserved.
//

import Foundation

public class BaseIteratableContext<ResultModel: Countable>: ServiceAsyncIterator, ActionableContext {

    // MARK: - Typealiases

    public typealias ResultType = ResultModel
    public typealias Model = ResultModel
    public typealias CompletedClosure = (ResultType) -> Void
    public typealias ErrorClosure = (Error) -> Void

    // MARK: - Private fileds

    private let startIndex: Int
    private var currentIndex: Int
    private let itemsOnPage: Int
    private let paginableContext: PagingRequestContext<ResultModel>
    private var completedClosure: CompletedClosure?
    private var errorClosure: ErrorClosure?

    // MARK: - Public properties

    public var canMoveNext: Bool

    // MARK: - Initializers

    public required init(startIndex: Int, itemsOnPage: Int, context: PagingRequestContext<ResultModel>) {
        self.startIndex = startIndex
        self.currentIndex = startIndex
        self.itemsOnPage = itemsOnPage
        self.canMoveNext = true
        self.paginableContext = context
        self.subscribe()
    }

    // MARK: - Iteratables

    public func moveNext() {
        self.paginableContext.pagin(startIndex: self.currentIndex, itemsOnPage: self.itemsOnPage)
    }

    public func reset(to index: Int? = nil) {
        guard let guardedIndex = index else {
            self.currentIndex = self.startIndex
            return
        }
        self.currentIndex = guardedIndex
    }

    // MARK: - Actionable context

    public func onCompleted(_ closure: @escaping CompletedClosure) {
        self.completedClosure = closure
    }

    public func onError(_ closure: @escaping ErrorClosure) {
        self.errorClosure = closure
    }
}

private extension BaseIteratableContext {

    func subscribe() {
        self.paginableContext.onCompleted { result in
            self.canMoveNext = result.itemsIsEmpty
            self.currentIndex += result.itemsCount
            self.completedClosure?(result)
        }

        self.paginableContext.onError { result in
            self.canMoveNext = false
            self.errorClosure?(result)
        }
    }
}
