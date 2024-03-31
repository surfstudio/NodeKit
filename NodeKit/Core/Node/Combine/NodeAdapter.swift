//
//  NodeAdapter.swift
//  NodeKit
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine

/// Протокол для выходных данных адаптера.
public protocol NodeAdapterOutput<Output> {
    associatedtype Output
    
    /// Метод отправки результата ноды.
    ///
    /// - Parameter value: результат ноды.
    func send(_ value: NodeResult<Output>)
}

/// Адаптер для мапинга интерфейса ноды на ``NodeAdapterOutput``.
public protocol NodeAdapter<Input, Output> {
    associatedtype Input
    associatedtype Output
    
    /// Метод содержащий логику мапинга обработки данных ноды на ``NodeAdapterOutput``,
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - logContext: Контекст логов.
    ///    - output: Output, в который будут переданы данные, полученные с ноды.
    func process(
        data: Input,
        logContext: LoggingContextProtocol,
        output: some NodeAdapterOutput<Output>
    ) async
}

/// Адаптер для мапинга интерфейса ``AsyncNode`` на ``NodeAdapterOutput``.
public struct AsyncNodeAdapter<Input, Output>: NodeAdapter {
    
    // MARK: - Private Properties
    
    private let node: any AsyncNode<Input, Output>
    
    // MARK: - Initialization
    
    public init(node: some AsyncNode<Input, Output>) {
        self.node = node
    }
    
    // MARK: - CombineAdapter
    
    /// Вызывает метод process у асинхронной ноды и передает результат в output.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - logContext: Контекст логов.
    ///    - output: Output, в который будут переданы данные, полученные с ноды.
    public func process(
        data: Input,
        logContext: LoggingContextProtocol,
        output: some NodeAdapterOutput<Output>
    ) async {
        let result = await node.process(data, logContext: logContext)
        output.send(result)
    }
}

/// Адаптер для мапинга интерфейса ``AsyncStreamNode`` на ``NodeAdapterOutput``.
public struct AsyncStreamNodeAdapter<Input, Output>: NodeAdapter {
    
    // MARK: - Private Properties
    
    private let node: any AsyncStreamNode<Input, Output>
    
    // MARK: - Initialization
    
    public init(node: some AsyncStreamNode<Input, Output>) {
        self.node = node
    }
    
    // MARK: - CombineAdapter
    
    /// Вызывает метод process у асинхронной ноды и передает результаты в output.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - logContext: Контекст логов.
    ///    - output: Output, в который будут переданы данные, полученные с ноды.
    public func process(
        data: Input,
        logContext: LoggingContextProtocol,
        output: some NodeAdapterOutput<Output>
    ) async {
        for await result in node.process(data, logContext: logContext) {
            output.send(result)
        }
    }
}
