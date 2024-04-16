//
//  AsyncStreamNodeMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public class AsyncStreamNodeMock<Input, Output>: AsyncStreamNode {
    
    public init() { }
    
    public var invokedAsyncStreamProcess = false
    public var invokedAsyncStreamProcessCount = 0
    public var invokedAsyncStreamProcessParameter: (data: Input, logContext: LoggingContextProtocol)?
    public var invokedAsyncStreamProcessParameterList: [(data: Input, logContext: LoggingContextProtocol)] = []
    public var stubbedAsyncStreamProccessResult: (() -> AsyncStream<NodeResult<Output>>)!
    public var stubbedAsyncStreamProcessRunFunction: (() -> Void)?
    
    public func process(_ data: Input, logContext: LoggingContextProtocol) -> AsyncStream<NodeResult<Output>> {
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
