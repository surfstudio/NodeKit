//
//  AsyncNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

/// Протокол наследованный от Node, добавляющий подход преобразования входных данных в результат с помощью SwiftConcurrency
/// Применим для узлов, которые возвращают один результат
public protocol AsyncNode<Input, Output>: CombineConvertibleNode {
    
    /// Ассинхронный метод, который содержит логику для обработки данных
    ///
    /// - Parameter data: Входные данные
    /// - Returns: Результат обработки данных.
    @discardableResult
    func process(_ data: Input, logContext: LoggingContextProtocol) async -> NodeResult<Output>
}

public extension AsyncNode {
    
    /// Метод process с созданием нового лог контекста.
    func process(_ data: Input) async -> NodeResult<Output> {
        return await process(data, logContext: LoggingContext())
    }
    
    /// Базовая реализация конвертации узла в ``CombineNode``.
    func combineNode() -> any CombineNode<Input, Output> {
        return CombineCompatibleNode(adapter: AsyncNodeAdapter(node: self))
    }
}

/// Содержит иснтаксический сахар для работы с узлами, у которых входящий тип = `Void`
public extension AsyncNode where Input == Void {
    
    /// Вызывает `process(_:)`
    func process() async -> NodeResult<Output> {
        return await process(Void())
    }
}
