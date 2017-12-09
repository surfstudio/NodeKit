//
//  BaseActiveRequestContext.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

/// Base implementation ActionableContext
/// - see: ActionableContext
public class ActiveRequestContext<Model>: ActionableContext {

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

    public func onCompleted(_ closure: @escaping CompletedClosure) {
        self.completedClosure = closure
    }

    public func onError(_ closure: @escaping ErrorClosure) {
        self.errorClosure = closure
    }

    public func perform() {
        self.request.performAsync { result in
            switch result {
            case .failure(let error):
                self.errorClosure?(error)
            case .success(let value, _):
                self.completedClosure?(value)
            }
        }
    }
}

public class BaseCacheableContext<Model>: ActiveRequestContext<Model>, CacheableContext {

    public typealias ResultType = Model

    fileprivate var completedCacheClosure: CompletedClosure?

    public func onCacheCompleted(_ closure: @escaping (ResultType) -> Void) {
        self.completedCacheClosure = closure
    }

    override public func perform() {
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
