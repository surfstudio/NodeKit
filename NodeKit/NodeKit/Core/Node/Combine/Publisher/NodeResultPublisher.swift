//
//  NodeResultPublisher.swift
//  NodeKit
//
//  Created by Andrei Frolov on 17.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine

/// Protocol describing a Publisher for ``CombineCompatibleNode``
protocol NodeResultPublisher<Node>: Publisher {
    associatedtype Node: CombineCompatibleNode
    
    /// Input data.
    var input: Node.I { get }
    
    /// Node.
    var node: Node { get }
    
    /// Logging context.
    var logContext: LoggingContextProtocol { get }
}
