//
//  RequestContext.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

/// Base implementation of PassiveContext
/// - see: PassiveContext
public class PassiveRequestContext<Model>: PassiveContextInterface<Model> {

    // MARK: - Typealiases

    public typealias ResultType = Model
    public typealias CompletedClosure = (ResultType) -> Void
    public typealias ErrorClosure = (Error) -> Void

    // MARK: - Private fields

    private var completedClosure: CompletedClosure?
    private var errorClosure: ErrorClosure?

    // MARK: - Context methods
    
    public override init() { }

    @discardableResult
    public override func onCompleted(_ closure: @escaping CompletedClosure) -> Self {
        self.completedClosure = closure
        return self
    }

    @discardableResult
    public override func onError(_ closure: @escaping ErrorClosure) -> Self {
        self.errorClosure = closure
        return self
    }

    public override func performComplete(result: ResultType) {
        self.completedClosure?(result)
    }

    public override func performError(error: Error) {
        self.errorClosure?(error)
    }

    #if DEBUG

    deinit {
        print("RequestContext DEINIT")
    }

    #endif
}
