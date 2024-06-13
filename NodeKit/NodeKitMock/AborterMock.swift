//
//  AborterMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public class AborterMock: Aborter {
    
    public init() { }
    
    public var invokedCancel = false
    public var invokedCancelCount = 0
 
    public func cancel() {
        invokedCancel = true
        invokedCancelCount += 1
    }

    public var invokedAsyncCancel = false
    public var invokedAsyncCancelCount = 0
    public var invokedAsyncCancelParameter: LoggingContextProtocol?
    public var invokedAsyncCancelParameterProtocol: [LoggingContextProtocol] = []
    
    public func cancel(logContext: LoggingContextProtocol) {
        invokedAsyncCancel = true
        invokedAsyncCancelCount += 1
        invokedAsyncCancelParameter = logContext
        invokedAsyncCancelParameterProtocol.append(logContext)
    }
}
