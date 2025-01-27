//
//  LoggingContextMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public actor LoggingContextMock: LoggingContextProtocol {
    public var method: Method?
    public var route: URLRouteProvider?

    public init() { }
    
    public private(set) var log: (LogableChain)?

    public var invokedAdd = false
    public var invokedAddCount = 0
    public var invokedAddParameter: LogableChain?
    public var invokedAddParameterList: [LogableChain?] = []

    public func add(_ log: LogableChain?) {
        invokedAdd = true
        invokedAddCount += 1
        invokedAddParameter = log
        invokedAddParameterList.append(log)
    }

    public var invokedSet = false
    public var invokedSetCount = 0
    public var invokedSetParameter: (Method?, URLRouteProvider?)?
    public var invokedSetParameterList: [(Method?, URLRouteProvider?)] = []

    public func set(method: Method?, route: URLRouteProvider?) {
        invokedSet = true
        invokedSetCount += 1
        invokedSetParameter = (method, route)
        invokedSetParameterList.append((method, route))
    }

    public var invokedSubscribe = false
    public var invokedSubscribeCount = 0
    public var invokedSubscribeParameter: (([Log]) -> Void)?
    public var invokedSubscribeParameterList: [([Log]) -> Void] = []

    public func subscribe(_ subscription: @escaping ([Log]) -> Void) {
        invokedSubscribe = true
        invokedSubscribeCount += 1
        invokedSubscribeParameter = subscription
        invokedSubscribeParameterList.append(subscription)
    }

    public var invokedComplete = false
    public var invokedCompleteCount = 0

    public func complete() {
        invokedComplete = true
        invokedCompleteCount += 1
    }
}
