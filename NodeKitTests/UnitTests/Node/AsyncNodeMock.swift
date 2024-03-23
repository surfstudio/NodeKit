//
//  AsyncNodeMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class AsyncNodeMock<Input, Output>: AsyncNode {
    
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
    
    var invokedAsyncProcess = false
    var invokedAsyncProcessCount = 0
    var invokedAsyncProcessParameter: Input?
    var invokedAsyncProcessParameterList: [Input] = []
    var stubbedAsyncProccessResult: NodeResult<Output>!
    var stubbedAsyncProcessRunFunction: (() async -> Void)?
    
    func process(_ data: Input, logContext: any LoggingContextProtocol) async -> NodeResult<Output> {
        invokedAsyncProcess = true
        invokedAsyncProcessCount += 1
        invokedAsyncProcessParameter = data
        invokedAsyncProcessParameterList.append(data)
        await stubbedAsyncProcessRunFunction?()
        return stubbedAsyncProccessResult
    }
}
