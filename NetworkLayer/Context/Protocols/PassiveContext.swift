//
//  Contextable.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

/// Provide interface for object, that must implement logic for call `onCompleted(_ cosure: )` and `onError(_ closure: )`
public protocol PassiveContext: ActionableContext {

    /// Call completed closure.
    ///
    /// - Parameter result: result for completed closure
    func performComplete(result: ResultType)

    /// Call error closure.
    ///
    /// - Parameter error: error for error closure
    func performError(error: Error)
}
