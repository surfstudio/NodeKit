//
//  PagingRequestContext.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 15.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

public class PagingRequestContext<ResultModel>: PaginableRequestContext {


    // MARK: - Typealiases

    public typealias ResultType = ResultModel
    public typealias CompletedClosure = (ResultType) -> Void
    public typealias ErrorClosure = (Error) -> Void

    // MARK: - Private fileds

    private var completedClosure: CompletedClosure?
    private var errorClosure: ErrorClosure?
    private let reques: BaseServerRequest<ResultType> & ReusablePagingRequest

    // MARK: - Initialization

    public required init(request: BaseServerRequest<ResultType> & ReusablePagingRequest) {
        self.reques = request
    }

    // MARK: - Context methods

    public func onCompleted(_ closure: @escaping CompletedClosure) {
        self.completedClosure = closure
    }

    public func onError(_ closure: @escaping ErrorClosure) {
        self.errorClosure = closure
    }

    // MARK: - Paginable context

    public func pagin(startIndex: Int, itemsOnPage: Int) {
        self.reques.reuse(startIndex: startIndex, itemsOnPage: itemsOnPage)
        self.perfromRequest()
    }

    private func perfromRequest() {
        self.reques.performAsync { result in
            switch result {
            case .failure(let error):
                self.errorClosure?(error)
            case .success(let value, _):
                self.completedClosure?(value)
            }
        }
    }
}
