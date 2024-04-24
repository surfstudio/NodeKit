//
//  CombineNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation
import Combine

/// Протокол ноды, выполняющая обработку данных и возвращающая результат с помощью Combine.
public protocol CombineNode<Input, Output>: Node {

    /// Метод запускающий процесс обработки данных
    /// и возвращающий publisher для подписки на результат.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - scheduler: Scheduler для выдачи результаты.
    ///    - logContext: Контекст логов.
    /// - Returns: Publisher для подписки на результат.
    @discardableResult
    func nodeResultPublisher(
        for data: Input,
        on scheduler: some Scheduler,
        logContext: LoggingContextProtocol
    ) -> AnyPublisher<NodeResult<Output>, Never>
}

public extension CombineNode {
    
    /// Метод запускающий процесс обработки данных и возвращаюший результат на главной очереди.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - logContext: Контекст логов.
    /// - Returns: Publisher для подписки на результат.
    @discardableResult
    func nodeResultPublisher(
        for data: Input,
        logContext: LoggingContextProtocol
    ) -> AnyPublisher<NodeResult<Output>, Never> {
        return nodeResultPublisher(for: data, on: DispatchQueue.main, logContext: logContext)
    }
    
    /// Метод запускающий процесс обработки данных, создающий новый контекст логов
    /// с использованием Scheduler для выдачи результаты.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - scheduler: Scheduler для выдачи результаты.
    /// - Returns: Publisher для подписки на результат.
    @discardableResult
    func nodeResultPublisher(for data: Input, on scheduler: some Scheduler) -> AnyPublisher<NodeResult<Output>, Never> {
        return nodeResultPublisher(for: data, on: scheduler, logContext: LoggingContext())
    }
    
    /// Метод запускающий процесс обработки данных, создающий новый контекст логов
    /// и возвращаюший результат на главной очереди.
    ///
    /// - Parameter data: Входные данные ноды.
    /// - Returns: Self ноды.
    @discardableResult
    func nodeResultPublisher(for data: Input) -> AnyPublisher<NodeResult<Output>, Never> {
        return nodeResultPublisher(for: data, on: DispatchQueue.main)
    }
}

/// Содержит иснтаксический сахар для работы с узлами, у которых входящий тип = `Void`
public extension CombineNode where Input == Void {
    
    /// Вызывает `process(_:)`
    @discardableResult
    func nodeResultPublisher() -> AnyPublisher<NodeResult<Output>, Never> {
        return nodeResultPublisher(for: Void())
    }
}
