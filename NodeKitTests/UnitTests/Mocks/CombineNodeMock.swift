//
//  CombineNodeMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 03.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import Combine

final class CombineNodeMock<Input, Output>: CombineNode {
    
    struct NodeResultPublisherParameters {
        let input: Input
        let scheduler: any Scheduler
        let logContext: LoggingContextProtocol
    }
    
    var invokedNodeResultPublisher = false
    var invokedNodeResultPublisherCount = 0
    var invokedNodeResultPublisherParameters: NodeResultPublisherParameters?
    var invokedNodeResultPublisherParametersList: [NodeResultPublisherParameters] = []
    var stubbedNodeResultPublisherResult: AnyPublisher<NodeResult<Output>, Never>!
    
    func nodeResultPublisher(for data: Input, on scheduler: some Scheduler, logContext: LoggingContextProtocol) -> AnyPublisher<NodeResult<Output>, Never> {
        let results = NodeResultPublisherParameters(input: data, scheduler: scheduler, logContext: logContext)
        invokedNodeResultPublisher = true
        invokedNodeResultPublisherCount += 1
        invokedNodeResultPublisherParameters = results
        invokedNodeResultPublisherParametersList.append(results)
        return stubbedNodeResultPublisherResult
    }
}
