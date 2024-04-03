//
//  AsyncStreamCombineNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 03.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation
import Combine

/// Реализация ``CombineStreamNode`` для ``AsyncStreamNode``.
public struct AsyncStreamCombineNode<Input, Output>: CombineStreamNode {
    
    // MARK: - Private Properties
    
    private let subject = PassthroughSubject<NodeResult<Output>, Never>()
    private let node: any AsyncStreamNode<Input, Output>
    
    // MARK: - Initialization
    
    init(node: some AsyncStreamNode<Input, Output>) {
        self.node = node
    }
    
    // MARK: - CombineNode
    
    /// Publisher результата обработки данных.
    /// - Parameter scheduler: Scheduler для выдачи результов.
    public func nodeResultPublisher(on scheduler: some Scheduler) -> AnyPublisher<NodeResult<Output>, Never> {
        return subject
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    /// Метод обработки данных протокола ``Node``. Будет удален в ближайшее время.
    public func processLegacy(_ data: Input) -> Observer<Output> {
        return node.processLegacy(data)
    }
    
    /// Метод запускающий процесс обработки данных.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - logContext: Контекст логов.
    public func process(_ data: Input, logContext: LoggingContextProtocol) {
        Task {
            for await result in node.process(data, logContext: logContext) {
                subject.send(result)
            }
        }
    }
}
