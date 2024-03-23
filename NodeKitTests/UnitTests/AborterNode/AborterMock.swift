//
//  AborterMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class AborterMock: Aborter {
    
    var invokedCancel = false
    var invokedCancelCount = 0
 
    func cancel() {
        invokedCancel = true
        invokedCancelCount += 1
    }

    var invokedAsyncCancel = false
    var invokedAsyncCancelCount = 0
    var invokedAsyncCancelParameter: LoggingContextProtocol?
    var invokedAsyncCancelParameterProtocol: [LoggingContextProtocol] = []
    
    func cancel(logContext: LoggingContextProtocol) {
        invokedAsyncCancel = true
        invokedAsyncCancelCount += 1
        invokedAsyncCancelParameter = logContext
        invokedAsyncCancelParameterProtocol.append(logContext)
    }
}
