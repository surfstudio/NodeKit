//
//  Contextable.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

/// `Passive` means that this context doesn't has any action.
/// So it may called "Proxy".
/// Provide interface for object, that must implement logic for call `onCompleted(_ cosure: )` and `onError(_ closure: )`.
public protocol PassiveContextProtocol: ActionableContextProtocol {

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
open class PassiveContext<ModelType>: ActionableContext<ModelType>, PassiveContextProtocol {

    public typealias ResultType = ModelType

    public override init() { }

    @discardableResult
    open override func onCompleted(_ closure: @escaping (ModelType) -> Void) -> Self {
        preconditionFailure("CoreNetKit.PassiveContextInterface \(#function) must be overrided in child")
    }

    @discardableResult
    open override func onError(_ closure: @escaping (Error) -> Void) -> Self {
        preconditionFailure("CoreNetKit.PassiveContextInterface \(#function) must be overrided in child")
    }


    open func performComplete(result: ResultType) {
        preconditionFailure("CoreNetKit.PassiveContextInterface \(#function) must be overrided in child")
    }

    open func performError(error: Error) {
        preconditionFailure("CoreNetKit.PassiveContextInterface \(#function) must be overrided in child")
    }
}
