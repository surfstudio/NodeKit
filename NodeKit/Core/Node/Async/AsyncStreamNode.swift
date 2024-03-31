//
//  AsyncStreamNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

/// Протокол наследованный от Node, добавляющий подход преобразования входных данных в поток результатов с помощью SwiftConcurrency
/// Применим для узлов, которые могут вернуть несколько результатов
public protocol AsyncStreamNode<Input, Output>: CombineConvertibleNode {
    
    /// Ассинхронный метод, который содержит логику для обработки данных
    ///
    /// - Parameter data: Входные данные
    /// - Returns: Поток результатов обработки данных.
    func process(_ data: Input, logContext: LoggingContextProtocol) -> AsyncStream<NodeResult<Output>>
}

public extension AsyncStreamNode {
    
    /// Базовая реализация конвертации узла в ``CombineNode``.
    func combineNode() -> any CombineNode<Input, Output> {
        return CombineCompatibleNode(adapter: AsyncStreamNodeAdapter(node: self))
    }
}
