//
//  AsyncCombineNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 03.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine

/// Реализация ``CombineNode`` для ``AsyncNode``.
public struct AsyncCombineNode<Input, Output>: CombineNode {
    
    // MARK: - Private Properties
    
    private let node: any AsyncNode<Input, Output>
    
    // MARK: - Initialization
    
    init(node: some AsyncNode<Input, Output>) {
        self.node = node
    }
    
    // MARK: - CombineNode
    
    /// Метод запускающий процесс обработки данных
    /// и возвращающий publisher для подписки на результат.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - queue: Очередь на которой будут выдаваться результаты.
    ///    - logContext: Контекст логов.
    /// - Returns: Publisher для подписки на результат.
    public func nodeResultPublisher(for data: Input, on scheduler: some Scheduler, logContext: LoggingContextProtocol) -> AnyPublisher<NodeResult<Output>, Never> {
        return Future<NodeResult<Output>, Never> { promise in
            Task {
                let result = await node.process(data, logContext: logContext)
                promise(.success(result))
            }
        }
        .receive(on: scheduler)
        .eraseToAnyPublisher()
    }
    
    public func processLegacy(_ data: Input) -> Observer<Output> {
        return node.processLegacy(data)
    }
}
