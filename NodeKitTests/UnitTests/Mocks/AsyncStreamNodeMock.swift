//
//  AsyncStreamNodeMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

class AsyncStreamNodeMock<Input, Output>: AsyncStreamNode {

    var invokedProcessLegacy = false
    var invokedProcessLegacyCount = 0
    var invokedProcessLegacyParameter: Input?
    var invokedProcessLegacyParameterList: [Input] = []
    var stubbedProccessLegacyResult: Observer<Output>!
    
    func processLegacy(_ data: Input) -> Observer<Output> {
        invokedProcessLegacy = true
        invokedProcessLegacyCount += 1
        invokedProcessLegacyParameter = data
        invokedProcessLegacyParameterList.append(data)
        return stubbedProccessLegacyResult
    }
    
    var invokedAsyncStreamProcess = false
    var invokedAsyncStreamProcessCount = 0
    var invokedAsyncStreamProcessParameter: (data: Input, logContext: LoggingContextProtocol)?
    var invokedAsyncStreamProcessParameterList: [(data: Input, logContext: LoggingContextProtocol)] = []
    var stubbedAsyncStreamProccessResult: (() -> AsyncStream<NodeResult<Output>>)!
    var stubbedAsyncStreamProcessRunFunction: (() -> Void)?
    
    func process(_ data: Input, logContext: LoggingContextProtocol) -> AsyncStream<NodeResult<Output>> {
        invokedAsyncStreamProcess = true
        invokedAsyncStreamProcessCount += 1
        invokedAsyncStreamProcessParameter = (data, logContext)
        invokedAsyncStreamProcessParameterList.append((data, logContext))
        if let function = stubbedAsyncStreamProcessRunFunction {
            function()
        }
        return stubbedAsyncStreamProccessResult()
    }
}
