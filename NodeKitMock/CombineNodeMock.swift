//
//  CombineNodeMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 03.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine
import NodeKit

public class CombineNodeMock<Input, Output>: CombineNode {
    
    public struct NodeResultPublisherParameters {
        public let input: Input
        public let scheduler: any Scheduler
        public let logContext: LoggingContextProtocol
    }
    
    public init() { }
    
    public var invokedNodeResultPublisher = false
    public var invokedNodeResultPublisherCount = 0
    public var invokedNodeResultPublisherParameters: NodeResultPublisherParameters?
    public var invokedNodeResultPublisherParametersList: [NodeResultPublisherParameters] = []
    public var stubbedNodeResultPublisherResult: AnyPublisher<NodeResult<Output>, Never>!
    
    public func nodeResultPublisher(for data: Input, on scheduler: some Scheduler, logContext: LoggingContextProtocol) -> AnyPublisher<NodeResult<Output>, Never> {
        let results = NodeResultPublisherParameters(input: data, scheduler: scheduler, logContext: logContext)
        invokedNodeResultPublisher = true
        invokedNodeResultPublisherCount += 1
        invokedNodeResultPublisherParameters = results
        invokedNodeResultPublisherParametersList.append(results)
        return stubbedNodeResultPublisherResult
    }
}
