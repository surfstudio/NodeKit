//
//  AsyncStreamNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine
import Foundation

/// Протокол, наследованный от Node, добавляющий подход преобразования входных данных в поток результатов с помощью SwiftConcurrency
/// Применим для узлов, которые могут вернуть несколько результатов
public protocol AsyncStreamNode<Input, Output>: Node {
    associatedtype Input
    associatedtype Output

    /// Ассинхронный метод, который содержит логику для обработки данных
    ///
    /// - Parameter data: Входные данные
    /// - Returns: Поток результатов обработки данных.
    @discardableResult
    func process(_ data: Input, logContext: LoggingContextProtocol) -> AsyncStream<NodeResult<Output>>
    
    /// Метод возвращающий объект для обработки результатов с помощью Combine.
    ///
    /// - Returns: Узел, поддерживающий обработку результатов с помощью Combine.
    func combineStreamNode() -> any CombineStreamNode<Input, Output>
}

public extension AsyncStreamNode {
    
    /// Метод process с созданием нового лог контекста.
    @discardableResult
    func process(_ data: Input) -> AsyncStream<NodeResult<Output>> {
        return process(data, logContext: LoggingContext())
    }
    /// Стандартная реализация конвертации узла в ``CombineStreamNode``.
    ///
    /// - Returns: Узел, поддерживающий обработку результатов с помощью Combine.
    func combineStreamNode() -> any CombineStreamNode<Input, Output> {
        return AsyncStreamCombineNode(node: self)
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
