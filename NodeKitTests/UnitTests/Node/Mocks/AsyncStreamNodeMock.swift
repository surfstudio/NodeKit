//
//  AsyncStreamNodeMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class AsyncStreamNodeMock<Input, Output>: AsyncStreamNode {

    var invokedProcess = false
    var invokedProcessCount = 0
    var invokedProcessParameter: Input?
    var invokedProcessParameterList: [Input] = []
    var stubbedProccessResult: Observer<Output>!
    
    func process(_ data: Input) -> Observer<Output> {
        invokedProcess = true
        invokedProcessCount += 1
        invokedProcessParameter = data
        invokedProcessParameterList.append(data)
        return stubbedProccessResult
    }
    
    var invokedAsyncStreamProcess = false
    var invokedAsyncStreamProcessCount = 0
    var invokedAsyncStreamProcessParameter: Input?
    var invokedAsyncStreamProcessParameterList: [Input] = []
    var stubbedAsyncStreamProccessResult: AsyncStream<NodeResult<Output>>!
    var stubbedAsyncStreamProcessRunFunction: (() -> Void)?
    
    func process(_ data: Input, logContext: LoggingContextProtocol) -> AsyncStream<NodeResult<Output>> {
        invokedAsyncStreamProcess = true
        invokedAsyncStreamProcessCount += 1
        invokedAsyncStreamProcessParameter = data
        invokedAsyncStreamProcessParameterList.append(data)
        if let function = stubbedAsyncStreamProcessRunFunction {
            function()
        }
        return stubbedAsyncStreamProccessResult
    }
}
