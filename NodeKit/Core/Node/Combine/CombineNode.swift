//
//  CombineNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine
import Foundation

/// Протокол ноды, поддерживающего обработку результата с помощью Combine.
public protocol CombineNode<Input, Output>: AnyObject {
    associatedtype Input
    associatedtype Output
    
    /// Метод запускающий процесс обработки данных.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - logContext: Контекст логов.
    /// - Returns: Self ноды.
    @discardableResult
    func process(data: Input, logContext: LoggingContextProtocol) -> Self
    
    /// Метод получения Publisher, для подписки на результат обработки данных в главном потоке.
    ///
    /// - Returns: Publisher результа обработки данных ноды.
    func eraseToAnyPublisher() -> AnyPublisher<NodeResult<Output>, Never>
    
    /// Метод получения Publisher, для подписки на результат обработки данных.
    ///
    /// - Parameter queue: Очередь, на которой будут получены данные.
    /// - Returns: Publisher результа обработки данных ноды.
    func eraseToAnyPublisher(queue: DispatchQueue) -> AnyPublisher<NodeResult<Output>, Never>
}

extension CombineNode {
    
    /// Метод запускающий процесс обработки данных и создающий новый контекст логов.
    /// 
    /// - Parameter data: Входные данные ноды.
    /// - Returns: Self ноды.
    @discardableResult
    func process(data: Input) -> Self {
        return process(data: data, logContext: LoggingContext())
    }
}

/// Реализация ``CombineNode``
public class CombineCompatibleNode<Input, Output>: CombineNode, NodeAdapterOutput {
    
    // MARK: - Private Properties

    private let subject = CurrentValueSubject<NodeResult<Output>?, Never>(nil)
    private let adapter: any NodeAdapter<Input, Output>
    
    // MARK: - Initialization

    public init(adapter: some NodeAdapter<Input, Output>) {
        self.adapter = adapter
    }
    
    // MARK: - CombineNode

    /// Создает новую задачу, в которой вызывает метод process у адаптера.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - logContext: Контекст логов.
    /// - Returns: Self ноды.
    @discardableResult
    public func process(data: Input, logContext: LoggingContextProtocol) -> Self {
        Task {
            await adapter.process(data: data, logContext: logContext, output: self)
        }
        return self
    }

    /// Метод получения Publisher, для подписки на результат обработки данных в главном потоке.
    ///
    /// - Returns: Publisher результа обработки данных ноды.
    public func eraseToAnyPublisher() -> AnyPublisher<NodeResult<Output>, Never> {
        return subject
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Метод получения Publisher, для подписки на результат обработки данных.
    ///
    /// - Parameter queue: Очередь, на которой будут получены данные.
    /// - Returns: Publisher результа обработки данных ноды.
    public func eraseToAnyPublisher(queue: DispatchQueue) -> AnyPublisher<NodeResult<Output>, Never> {
        return subject
            .compactMap { $0 }
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
    
    // MARK: - NodeAdapterOutput
    
    public func send(_ value: NodeResult<Output>) {
        subject.send(value)
    }
}
