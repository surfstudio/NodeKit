//
//  AsyncNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine
import Foundation

/// Протокол, наследованный от Node, добавляющий подход преобразования входных данных в результат с помощью SwiftConcurrency.
/// Применим для узлов, которые возвращают один результат.
public protocol AsyncNode<Input, Output>: Node {
    associatedtype Input
    associatedtype Output

    /// Ассинхронный метод, который содержит логику для обработки данных
    ///
    /// - Parameter data: Входные данные
    /// - Returns: Результат обработки данных.
    @discardableResult
    func process(_ data: Input, logContext: LoggingContextProtocol) async -> NodeResult<Output>
    
    /// Метод, возвращающий объект для обработки результатов с помощью Combine.
    ///
    /// - Returns: Узел, поддерживающий обработку результатов с помощью Combine.
    func combineNode() -> any CombineNode<Input, Output>
    
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
    
    /// Стандартная реализация конвертации узла в ``CombineNode``.
    ///
    /// - Returns: Узел, поддерживающий обработку результатов с помощью Combine.
    func combineNode() -> any CombineNode<Input, Output> {
        return AsyncCombineNode(node: self)
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
