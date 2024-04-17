//
//  AsyncStreamNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine
import Foundation

/// Протокол ноды, описывающий подход преобразования входных данных в результат с помощью SwiftConcurrency.
/// Поддерживает обработку результатов с помощью Combine, наследуя протокол ``CombineCompatibleNode``.
/// Содержит параметры для логов, наследуя протокол ``LoggableNode``.
/// Применим для узлов, которые могут вернуть несколько результатов
public protocol AsyncStreamNode<Input, Output>: LoggableNode, CombineCompatibleNode<Self.Input, Self.Output> {
    associatedtype Input
    associatedtype Output
    
    /// Ассинхронный метод, который содержит логику для обработки данных
    ///
    /// - Parameter data: Входные данные
    /// - Returns: Поток результатов обработки данных.
    @discardableResult
    func process(_ data: Input, logContext: LoggingContextProtocol) -> AsyncStream<NodeResult<Output>>
    
    /// Метод, возвращающий структуру-обертку текущей ноды.
    /// Необходим для избежания проблем, возникающих при использовании any AsyncStreamNode
    ///
    /// - Returns: Cтруктура-обертку текущей ноды ``AnyAsyncStreamNode``.
    func eraseToAnyNode() -> AnyAsyncStreamNode<Input, Output>
}

public extension AsyncStreamNode {
    
    /// Метод process с созданием нового лог контекста.
    @discardableResult
    func process(_ data: Input) -> AsyncStream<NodeResult<Output>> {
        return process(data, logContext: LoggingContext())
    }

    /// Метод получения Publisher для подписки на результат.
    /// Базовая реализация ``CombineCompatibleNode``.
    /// При каждой подписке вызывает метод process с новой таской.
    /// При вызове cancel вызывает cancel у таски.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - scheduler: Scheduler для выдачи результата.
    ///    - logContext: Контекст логов.
    /// - Returns: Publisher для подписки на результат.
    @discardableResult
    func nodeResultPublisher(
        for data: Input,
        on scheduler: some Scheduler,
        logContext: LoggingContextProtocol
    ) -> AnyPublisher<NodeResult<Output>, Never> {
        return AsyncStreamNodeResultPublisher(node: self, input: data, logContext: logContext)
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    /// Метод, возвращающий структуру-обертку текущей ноды.
    /// Необходим для избежания проблем, возникающих при использовании any AsyncStreamNode
    ///
    /// - Returns: Cтруктура-обертку текущей ноды ``AnyAsyncStreamNode``.
    func eraseToAnyNode() -> AnyAsyncStreamNode<Input, Output> {
        return AnyAsyncStreamNode(node: self)
    }
}

/// Содержит синтаксический сахар для работы с узлами, у которых входящий тип = `Void`
public extension AsyncStreamNode where Input == Void {
    
    /// Вызывает `process(_:)`
    @discardableResult
    func process() -> AsyncStream<NodeResult<Output>> {
        return process(Void())
    }
}
