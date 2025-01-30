//
//  LogSession.swift
//
//
//  Created by frolov on 24.12.2024.
//

public protocol LogSession: Actor {

    /// Request Method
    var method: Method? { get }
    /// Request Route
    var route: URLRouteProvider? { get }

    func subscribe(_ subscription: @escaping ([Log]) async -> Void)
}
