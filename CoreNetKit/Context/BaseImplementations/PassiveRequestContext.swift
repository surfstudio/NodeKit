//
//  RequestContext.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

/// Base implementation of PassiveContext
/// - see: PassiveContext
public class PassiveRequestContext<Model>: PassiveContext {

    // MARK: - Typealiases

    public typealias ResultType = Model
    public typealias CompletedClosure = (ResultType) -> Void
    public typealias ErrorClosure = (Error) -> Void

    // MARK: - Private fields

    private var completedClosure: CompletedClosure?
    private var errorClosure: ErrorClosure?

    // MARK: - Context methods
    
    public init() { }

    @discardableResult
    public func onCompleted(_ closure: @escaping CompletedClosure) -> Self {
        self.completedClosure = closure
        return self
    }

    @discardableResult
    public func onError(_ closure: @escaping ErrorClosure) -> Self {
        self.errorClosure = closure
        return self
    }

    public func performComplete(result: ResultType) {
        self.completedClosure?(result)
    }

    public func performError(error: Error) {
        self.errorClosure?(error)
    }

    #if DEBUG

    deinit {
        print("RequestContext DEINIT")
    }

    #endif
}
