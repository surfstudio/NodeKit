//
//  CombineStreamNodeMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 03.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import Combine

final class CombineStreamNodeMock<Input, Output>: CombineStreamNode {
    
    var invokedNodeResultPublisher = false
    var invokedNodeResultPublisherCount = 0
    var invokedNodeResultPublisherParameter: (any Scheduler)?
    var invokedNodeResultPublisherParameterList: [any Scheduler] = []
    var stubbedNodeResultPublisherResult: AnyPublisher<NodeResult<Output>, Never>!
    
    func nodeResultPublisher(on scheduler: some Scheduler) -> AnyPublisher<NodeResult<Output>, Never> {
        invokedNodeResultPublisher = true
        invokedNodeResultPublisherCount += 1
        invokedNodeResultPublisherParameter = scheduler
        invokedNodeResultPublisherParameterList.append(scheduler)
        return stubbedNodeResultPublisherResult
    }
    
    var invokedProcess = false
    var invokedProcessCount = 0
    var invokedProcessParameters: (data: Input, logContext: LoggingContextProtocol)?
    var invokedProcessParameterList: [(data: Input, logContext: LoggingContextProtocol)] = []
    
    func process(_ data: Input, logContext: LoggingContextProtocol) {
        invokedProcess = true
        invokedProcessCount += 1
        invokedProcessParameters = (data, logContext)
        invokedProcessParameterList.append((data, logContext))
    }
}
