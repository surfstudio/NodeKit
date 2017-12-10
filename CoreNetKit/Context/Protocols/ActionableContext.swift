//
//  ActionableContext.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

/// Base context for any more complex contexts.
/// Provides Rx-like interface for handling success and errors of response.
public protocol ActionableContext {

    associatedtype ResultType

    /// Called if coupled object completed operation succesfully
    ///
    /// - Parameter closure: callback
    @discardableResult
    func onCompleted(_ closure: @escaping (ResultType) -> Void) -> Self

    /// Called if coupled object's operation completed with error
    ///
    /// - Parameter closure: callback
    @discardableResult
    func onError(_ closure: @escaping (Error) -> Void) -> Self
}
