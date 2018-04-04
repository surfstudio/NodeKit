//
//  BaseActiveRequestContext.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

/// Base implementation `ActionableContext`
public class ActiveRequestContext<Model>: ActionableContext<Model>, CancellableContext {

    // MARK: - Typealiases

    public typealias ResultType = Model
    public typealias CompletedClosure = (ResultType) -> Void
    public typealias ErrorClosure = (Error) -> Void

    // MARK: - Private fields

    fileprivate var completedClosure: CompletedClosure?
    fileprivate var errorClosure: ErrorClosure?
    fileprivate let request: BaseServerRequest<Model>

    // MARK: - Initializers / Deinitializers

    public required init(request: BaseServerRequest<Model>) {
        self.request = request
    }

    #if DEBUG

    deinit {
        print("ActiveRequestContext DEINIT")
    }

    #endif

    // MARK: - Context methods

    @discardableResult
    open override func onCompleted(_ closure: @escaping CompletedClosure) -> Self {
        self.completedClosure = closure
        return self
    }

    @discardableResult
    open override func onError(_ closure: @escaping ErrorClosure) -> Self {
        self.errorClosure = closure
        return self
    }

    open func perform() {
        self.request.performAsync { self.performHandler(result: $0) }
    }

    open func cancel() {
        self.request.cancel()
    }

    open func safePerform(manager: AccessSafeManager) {
        let request = ServiceSafeRequest(request: self.request) { self.performHandler(result: $0) }
        manager.addRequest(request: request)
    }

    private func performHandler(result: ResponseResult<Model>) {
        switch result {
        case .failure(let error):
            self.errorClosure?(error)
        case .success(let value, _):
            self.completedClosure?(value)
        }
    }
}

public class BaseCacheableContext<Model>: ActiveRequestContext<Model>, CacheableContextProtocol {

    public typealias ResultType = Model

    fileprivate var completedCacheClosure: CompletedClosure?

    @discardableResult
    open func onCacheCompleted(_ closure: @escaping (ResultType) -> Void) -> Self {
        self.completedCacheClosure = closure
        return self
    }

    override open func perform() {
        self.request.performAsync { result in
            switch result {
            case .failure(let error):
                self.errorClosure?(error)
            case .success(let value, let cacheFlag):
                if cacheFlag {
                    self.completedCacheClosure?(value)
                } else {
                    self.completedClosure?(value)
                }
            }
        }
    }
}
