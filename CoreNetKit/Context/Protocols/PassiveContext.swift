//
//  Contextable.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

/// Provide interface for object, that must implement logic for call `onCompleted(_ cosure: )` and `onError(_ closure: )`.
/// Its something like backside of ActionableContext.
public protocol PassiveContext: ActionableContext {

    /// Call completed closure.
    ///
    /// - Parameter result: result for completed closure
    func performComplete(result: ResultType)

    /// Call error closure.
    ///
    /// - Parameter error: error for error closure
    func performError(error: Error)
}

/// Just a type erasure for `PassiveContext`
open class PassiveContextInterface<ModelType>: PassiveContext {

    public typealias ResultType = ModelType

    public init() { }

    @discardableResult
    public func onCompleted(_ closure: @escaping (ModelType) -> Void) -> Self {
        preconditionFailure("CoreNetKit.PassiveContextInterface \(#function) must be overrided in child")
    }

    @discardableResult
    public func onError(_ closure: @escaping (Error) -> Void) -> Self {
        preconditionFailure("CoreNetKit.PassiveContextInterface \(#function) must be overrided in child")
    }


    open func performComplete(result: ResultType) {
        preconditionFailure("CoreNetKit.PassiveContextInterface \(#function) must be overrided in child")
    }

    open func performError(error: Error) {
        preconditionFailure("CoreNetKit.PassiveContextInterface \(#function) must be overrided in child")
    }
}
