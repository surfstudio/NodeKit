//
//  CacheableContext.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 09.12.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

/// Divide success completion on cache completion and server completion
public protocol CacheableContextProtocol: ActionableContextProtocol{

    /// Called if coupled object completed operation succesfully
    ///
    /// - Parameter closure: callback
    @discardableResult
    func onCacheCompleted(_ closure: @escaping (ResultType) -> Void) -> Self
}

/// Type erasure for `CacheableContext`
open class CacheableContext<ModelType>: CacheableContextProtocol {

    public typealias ResultType = ModelType

    public init() { }

    @discardableResult
    open func onCompleted(_ closure: @escaping (ModelType) -> Void) -> Self {
        preconditionFailure("CoreNetKit.ActionableContextProtocol \(#function) must be overrided in child")
    }

    @discardableResult
    open func onError(_ closure: @escaping (Error) -> Void) -> Self {
        preconditionFailure("CoreNetKit.ActionableContextProtocol \(#function) must be overrided in child")
    }

    @discardableResult
    open func onCacheCompleted(_ closure: @escaping (ModelType) -> Void) -> Self {
        preconditionFailure("CoreNetKit.CacheableContextProtocol \(#function) must be overrided in child")
    }
}
