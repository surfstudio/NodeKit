//
//  PagingRequestContext.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 15.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation
import CoreEvents

/// Context for paginable service
public class PagingRequestContext<ResultModel>: PaginableRequestContextProtocol {

    // MARK: - Typealiases

    public typealias ResultType = ResultModel
    public typealias CompletedClosure = (ResultType) -> Void
    public typealias ErrorClosure = (Error) -> Void

    // MARK: - Private fileds

    private var completedEvents: Event<ResultType>
    private var errorEvents: Event<Error>
    private let request: BaseServerRequest<ResultType> & ReusablePagingRequest

    // MARK: - Initialization

    public required init(request: BaseServerRequest<ResultType> & ReusablePagingRequest,
                         completedEvents: Event<ResultType> = PresentEvent<ResultType>(), errorEvents: Event<Error> = PresentEvent<Error>()) {
        self.request = request
        self.completedEvents = completedEvents
        self.errorEvents = errorEvents
    }

    // MARK: - Context methods

    @discardableResult
    public func onCompleted(_ closure: @escaping CompletedClosure) -> Self {
        self.completedEvents += closure
        return self
    }

    @discardableResult
    public func onError(_ closure: @escaping ErrorClosure) -> Self {
        self.errorEvents += closure
        return self
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
            self.errorEvents.invoke(with: error)
        case .success(let value, _):
            self.completedEvents.invoke(with: value)
        }
    }
}
