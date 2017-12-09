//
//  PagingRequestContext.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 15.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

/// Context for paginable service
public class PagingRequestContext<ResultModel>: PaginableRequestContext {


    // MARK: - Typealiases

    public typealias ResultType = ResultModel
    public typealias CompletedClosure = (ResultType) -> Void
    public typealias ErrorClosure = (Error) -> Void

    // MARK: - Private fileds

    private var completedClosure: CompletedClosure?
    private var errorClosure: ErrorClosure?
    private let request: BaseServerRequest<ResultType> & ReusablePagingRequest

    // MARK: - Initialization

    public required init(request: BaseServerRequest<ResultType> & ReusablePagingRequest) {
        self.request = request
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
        self.request.reuse(startIndex: startIndex, itemsOnPage: itemsOnPage)
        self.perfromRequest()
    }

    private func perfromRequest() {
        self.request.performAsync { self.performHandler(result: $0) }
    }

    public func safePerform(manager: AccessSafeManager) {
        let request = ServiceSafeRequest(request: self.request) { self.performHandler(result: $0) }
        manager.addRequest(request: request)
    }

    private func performHandler(result: ResponseResult<ResultModel>) {
        switch result {
        case .failure(let error):
            self.errorClosure?(error)
        case .success(let value, _):
            self.completedClosure?(value)
        }
    }
}
