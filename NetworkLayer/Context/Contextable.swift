//
//  Contextable.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

public protocol Contextable {

    associatedtype ResultType

    /// Called if coupled object completed operation succesfully
    ///
    /// - Parameter closure: callback
    func onCompleted(_ closure: @escaping (ResultType) -> Void)

    /// Called if coupled object's operation completed with error
    ///
    /// - Parameter closure: callback
    func onError(_ closure: @escaping (Error) -> Void)
}
