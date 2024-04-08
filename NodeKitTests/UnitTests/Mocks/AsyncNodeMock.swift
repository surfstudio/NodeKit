//
//  AsyncNodeMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import Combine

class AsyncNodeMock<Input, Output>: AsyncNode {
    
    var invokedAsyncProcess = false
    var invokedAsyncProcessCount = 0
    var invokedAsyncProcessParameters: (data: Input, logContext: LoggingContextProtocol)?
    var invokedAsyncProcessParametersList: [(data: Input, logContext: LoggingContextProtocol)] = []
    var stubbedAsyncProccessResult: NodeResult<Output>!
    var stubbedAsyncProcessRunFunction: (() async -> Void)?
    var stubbedAsyncProcessNonAsyncRunFunction: (() -> Void)?
    
    func process(_ data: Input, logContext: LoggingContextProtocol) async -> NodeResult<Output> {
        invokedAsyncProcess = true
        invokedAsyncProcessCount += 1
        invokedAsyncProcessParameters = (data, logContext)
        invokedAsyncProcessParametersList.append((data, logContext))
        if let function = stubbedAsyncProcessRunFunction {
            await function()
        }
        stubbedAsyncProcessNonAsyncRunFunction?()
        return stubbedAsyncProccessResult
    }
}
