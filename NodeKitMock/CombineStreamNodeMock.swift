//
//  CombineStreamNodeMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 03.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine
import NodeKit

public class CombineStreamNodeMock<Input, Output>: CombineStreamNode {
    public init() { }
    
    public var invokedNodeResultPublisher = false
    public var invokedNodeResultPublisherCount = 0
    public var invokedNodeResultPublisherParameter: (any Scheduler)?
    public var invokedNodeResultPublisherParameterList: [any Scheduler] = []
    public var stubbedNodeResultPublisherResult: AnyPublisher<NodeResult<Output>, Never>!
    
    public func nodeResultPublisher(on scheduler: some Scheduler) -> AnyPublisher<NodeResult<Output>, Never> {
        invokedNodeResultPublisher = true
        invokedNodeResultPublisherCount += 1
        invokedNodeResultPublisherParameter = scheduler
        invokedNodeResultPublisherParameterList.append(scheduler)
        return stubbedNodeResultPublisherResult
    }
    
    public var invokedProcess = false
    public var invokedProcessCount = 0
    public var invokedProcessParameters: (data: Input, logContext: LoggingContextProtocol)?
    public var invokedProcessParameterList: [(data: Input, logContext: LoggingContextProtocol)] = []
    
    public func process(_ data: Input, logContext: LoggingContextProtocol) {
        invokedProcess = true
        invokedProcessCount += 1
        invokedProcessParameters = (data, logContext)
        invokedProcessParameterList.append((data, logContext))
    }
}
