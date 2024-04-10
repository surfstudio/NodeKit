//
//  AsyncNodeMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine
import NodeKit

public class AsyncNodeMock<Input, Output>: AsyncNode {
    public init() { }
    
    public var invokedAsyncProcess = false
    public var invokedAsyncProcessCount = 0
    public var invokedAsyncProcessParameters: (data: Input, logContext: LoggingContextProtocol)?
    public var invokedAsyncProcessParametersList: [(data: Input, logContext: LoggingContextProtocol)] = []
    public var stubbedAsyncProccessResult: NodeResult<Output>!
    public var stubbedAsyncProcessRunFunction: (() async -> Void)?
    public var stubbedAsyncProcessNonAsyncRunFunction: (() -> Void)?
    
    public func process(_ data: Input, logContext: LoggingContextProtocol) async -> NodeResult<Output> {
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
