//
//  AnyAsyncStreamNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 02.05.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

struct AnyAsyncStreamNode<Input, Output>: AsyncStreamNode {
    
    // MARK: - Private Properties
    
    private let node: any AsyncStreamNode<Input, Output>
    
    // MARK: - Initialization
    
    init(node: any AsyncStreamNode<Input, Output>) {
        self.node = node
    }
    
    // MARK: - AsyncNode
    
    func process(_ data: Input, logContext: LoggingContextProtocol) -> AsyncStream<NodeResult<Output>> {
        return node.process(data, logContext: logContext)
    }
}
