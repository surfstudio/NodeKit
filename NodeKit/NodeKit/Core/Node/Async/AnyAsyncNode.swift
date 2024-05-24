//
//  AnyAsyncNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 02.05.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

public struct AnyAsyncNode<Input, Output>: AsyncNode {
    
    // MARK: - Private Properties
    
    private let node: any AsyncNode<Input, Output>
    
    // MARK: - Initialization
    
    init(node: any AsyncNode<Input, Output>) {
        self.node = node
    }
    
    // MARK: - AsyncNode
    
    public func process(_ data: Input, logContext: LoggingContextProtocol) async -> NodeResult<Output> {
        return await node.process(data, logContext: logContext)
    }
}
