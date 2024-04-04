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
    
    var invokedProcessLegacy = false
    var invokedProcessLegacyCount = 0
    var invokedProcessLegacyParameter: Input?
    var invokedProcessLegacyParameterList: [Input] = []
    var stubbedProcessLegacyRunFunction: (() -> Void)?
    var stubbedProccessLegacyResult: Observer<Output>!
    
    func processLegacy(_ data: Input) -> Observer<Output> {
        invokedProcessLegacy = true
        invokedProcessLegacyCount += 1
        invokedProcessLegacyParameter = data
        invokedProcessLegacyParameterList.append(data)
        stubbedProcessLegacyRunFunction?()
        return stubbedProccessLegacyResult
    }
    
    var invokedAsyncProcess = false
    var invokedAsyncProcessCount = 0
    var invokedAsyncProcessParameters: (Input, LoggingContextProtocol)?
    var invokedAsyncProcessParametersList: [(Input, LoggingContextProtocol)] = []
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
