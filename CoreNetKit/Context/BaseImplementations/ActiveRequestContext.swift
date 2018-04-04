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

    fileprivate var completedEvents: Event<ResultType>
    fileprivate var errorEvents: Event<Error>
    fileprivate let request: BaseServerRequest<Model>

    // MARK: - Initializers / Deinitializers

    public required init(request: BaseServerRequest<Model>) {
        self.request = request
        self.completedEvents = Event<ResultType>()
        self.errorEvents = Event<Error>()
    }

    #if DEBUG

    deinit {
        print("ActiveRequestContext DEINIT")
    }

    #endif

    // MARK: - Context methods

    @discardableResult
    open override func onCompleted(_ closure: @escaping CompletedClosure) -> Self {
        self.completedEvents += closure
        return self
    }

    @discardableResult
    open override func onError(_ closure: @escaping ErrorClosure) -> Self {
        self.errorEvents += closure
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
            self.errorEvents.invoke(with: error)
        case .success(let value, _):
            self.completedEvents.invoke(with: value)
        }
    }
}

public class BaseCacheableContext<Model>: ActiveRequestContext<Model>, CacheableContextProtocol {

    public typealias ResultType = Model

    fileprivate var completedCacheEvent: Event<ResultType>

    public required init(request: BaseServerRequest<Model>) {
        self.completedCacheEvent = Event<ResultType>()
        super.init(request: request)
    }

    @discardableResult
    open func onCacheCompleted(_ closure: @escaping (ResultType) -> Void) -> Self {
        self.completedCacheEvent += closure
        return self
    }

    override open func perform() {
        self.request.performAsync { result in
            switch result {
            case .failure(let error):
                self.errorEvents.invoke(with: error)
            case .success(let value, let cacheFlag):
                if cacheFlag {
                    self.completedCacheEvent.invoke(with: value)
                } else {
                    self.completedEvents.invoke(with: value)
                }
            }
        }
    }
}
