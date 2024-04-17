//
//  CombineCompatibleNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 17.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine

/// Протокол ноды, выполняющая обработку данных и возвращающая результат с помощью Combine.
public protocol CombineCompatibleNode<I, O> {
    associatedtype I
    associatedtype O
    
    /// Метод получения Publisher для подписки на результат.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - scheduler: Scheduler для выдачи результата.
    ///    - logContext: Контекст логов.
    /// - Returns: Publisher для подписки на результат.
    func nodeResultPublisher(
        for data: I,
        on scheduler: some Scheduler,
        logContext: LoggingContextProtocol
    ) -> AnyPublisher<NodeResult<O>, Never>
}

public extension CombineCompatibleNode {
    
    /// Метод получения Publisher, возвращающего результат на главной очереди.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - logContext: Контекст логов.
    /// - Returns: Publisher для подписки на результат.
    @discardableResult
    func nodeResultPublisher(
        for data: I,
        logContext: LoggingContextProtocol
    ) -> AnyPublisher<NodeResult<O>, Never> {
        return nodeResultPublisher(for: data, on: DispatchQueue.main, logContext: logContext)
    }
    
    /// Метод получения Publisher с новым лог контекстом
    /// и кастомного Scheduler для выдачи результата.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - scheduler: Scheduler для выдачи результата.
    /// - Returns: Publisher для подписки на результат.
    @discardableResult
    func nodeResultPublisher(
        for data: I,
        on scheduler: some Scheduler
    ) -> AnyPublisher<NodeResult<O>, Never> {
        return nodeResultPublisher(for: data, on: scheduler, logContext: LoggingContext())
    }
    
    /// Метод получения Publisher с новым лог контекстом, возвращающего результат на главной очереди.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    /// - Returns: Publisher для подписки на результат.
    @discardableResult
    func nodeResultPublisher(
        for data: I
    ) -> AnyPublisher<NodeResult<O>, Never> {
        return nodeResultPublisher(for: data, on: DispatchQueue.main)
    }
}

/// Содержит синтаксический сахар для работы с узлами, у которых входящий тип = `Void`
public extension CombineCompatibleNode where I == Void {
    
    /// Метод получения Publisher с кастомным Scheduler.
    ///
    /// - Parameters:
    ///    - scheduler: Scheduler для выдачи результата.
    ///    - logContext: Контекст логов.
    /// - Returns: Publisher для подписки на результат.
    func nodeResultPublisher(
        on scheduler: some Scheduler,
        logContext: LoggingContextProtocol
    ) -> AnyPublisher<NodeResult<O>, Never> {
        return nodeResultPublisher(for: Void(), on: scheduler, logContext: logContext)
    }
    
    /// Метод получения Publisher с кастомным Scheduler и созданием нового лог контекста.
    ///
    /// - Parameters:
    ///    - scheduler: Scheduler для выдачи результата.
    /// - Returns: Publisher для подписки на результат.
    @discardableResult
    func nodeResultPublisher(
        on scheduler: some Scheduler
    ) -> AnyPublisher<NodeResult<O>, Never> {
        return nodeResultPublisher(for: Void(), on: scheduler)
    }
    
    /// Метод получения Publisher, возвращающего результат на главной очереди.
    ///
    /// - Parameters:
    ///    - logContext: Контекст логов.
    /// - Returns: Publisher для подписки на результат.
    func nodeResultPublisher(
        logContext: LoggingContextProtocol
    ) -> AnyPublisher<NodeResult<O>, Never> {
        return nodeResultPublisher(for: Void(), logContext: logContext)
    }
    
    /// Метод получения Publisher с новым лог контекстом, возвращающего результат на главной очереди.
    ///
    /// - Returns: Publisher для подписки на результат.
    @discardableResult
    func nodeResultPublisher(
    ) -> AnyPublisher<NodeResult<O>, Never> {
        return nodeResultPublisher(for: Void())
    }
}
