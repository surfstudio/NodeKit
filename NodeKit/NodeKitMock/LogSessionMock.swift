//
//  LogSession.swift
//
//
//  Created by frolov on 24.12.2024.
//

import NodeKit

public actor LogSessionMock: LogSession {
    public var method: Method?
    public var route: (URLRouteProvider)?

    public var invokedSubscribe = false
    public var invokedSubscribeCount = 0
    public var invokedSubscribeParameter: (([Log]) async -> Void)?
    public var invokedSubscribeParameterList: [([Log]) async -> Void] = []

    public func subscribe(_ subscription: @escaping ([Log]) async -> Void) {
        invokedSubscribe = true
        invokedSubscribeCount += 1
        invokedSubscribeParameter = subscription
        invokedSubscribeParameterList.append(subscription)
    }
}
