//
//  AsyncNode.swift
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
/// Применим для узлов, которые возвращают один результат.
public protocol AsyncNode<Input, Output>: LoggableNode, CombineCompatibleNode<Self.Input, Self.Output> {
    associatedtype Input
    associatedtype Output

    /// Ассинхронный метод, который содержит логику для обработки данных
    ///
    /// - Parameter data: Входные данные
    /// - Returns: Результат обработки данных.
    @discardableResult
    func process(_ data: Input, logContext: LoggingContextProtocol) async -> NodeResult<Output>
    
    /// Метод, возвращающий структуру-обертку текущей ноды.
    /// Необходим для избежания проблем, возникающих при использовании any AsyncNode
    ///
    /// - Returns: Cтруктура-обертку текущей ноды ``AnyAsyncNode``.
    func eraseToAnyNode() -> AnyAsyncNode<Input, Output>
    
    /// Метод, позволяющий объединить две ноды с одинаковыми Input и Output в AsyncStreamNode.
    ///
    /// - Parameter node: Нода, необходимая для объединения.
    /// - Returns: Нода AsyncStreamNode, включающая текущую и переданную ноду.
    func merged(with node: any AsyncNode<Input, Output>) -> any AsyncStreamNode<Input, Output>
}

public extension AsyncNode {
    
    /// Метод process с созданием нового лог контекста.
    @discardableResult
    func process(_ data: Input) async -> NodeResult<Output> {
        return await process(data, logContext: LoggingContext())
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
        return AsyncNodeResultPublisher(node: self, input: data, logContext: logContext)
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    /// Метод, возвращающий структуру-обертку текущей ноды.
    /// Необходим для избежания проблем, возникающих при использовании any AsyncNode
    ///
    /// - Returns: Cтруктура-обертку текущей ноды ``AnyAsyncNode``.
    func eraseToAnyNode() -> AnyAsyncNode<Input, Output> {
        return AnyAsyncNode(node: self)
    }
    
    /// Стандартная реализация объединения двух узлов в AsyncStreamNode.
    ///
    /// - Parameter node: Нода, необходимая для объединения.
    /// - Returns: Нода AsyncStreamNode, включающая текущую и переданную ноду.
    func merged(with node: any AsyncNode<Input, Output>) -> any AsyncStreamNode<Input, Output> {
        return MergedAsyncStreamNode(firstNode: self, secondNode: node)
    }
}

/// Содержит синтаксический сахар для работы с узлами, у которых входящий тип = `Void`
public extension AsyncNode where Input == Void {
    
    /// Вызывает `process(_:)`
    @discardableResult
    func process() async -> NodeResult<Output> {
        return await process(Void())
    }
}
