//
//  NodeResultPublisher.swift
//  NodeKit
//
//  Created by Andrei Frolov on 17.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine

/// Протокол описывающий Publisher для ``CombineCompatibleNode``
protocol NodeResultPublisher<Node>: Publisher {
    associatedtype Node: CombineCompatibleNode
    
    /// Входные данные.
    var input: Node.I { get }
    
    /// Нода.
    var node: Node { get }
    
    /// Контекст логов.
    var logContext: LoggingContextProtocol { get }
}
