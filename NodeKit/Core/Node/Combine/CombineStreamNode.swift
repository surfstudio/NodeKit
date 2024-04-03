//
//  PublisherContainerNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine
import Foundation

/// Протокол ноды, хранящий в себе publisher результатов обработки данных.
/// Используется для потока данных, когда необходимо выполнить подписку до начала обработки.
public protocol CombineStreamNode<Input, Output>: Node {

    /// Publisher результата обработки данных.
    /// - Parameter scheduler: Scheduler для выдачи результаты..
    func nodeResultPublisher(on scheduler: some Scheduler) -> AnyPublisher<NodeResult<Output>, Never>
    
    /// Метод запускающий процесс обработки данных.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - logContext: Контекст логов.
    func process(_ data: Input, logContext: LoggingContextProtocol)
}

public extension CombineStreamNode {
    
    /// Метод запускающий процесс обработки данных с созданием нового контекста логов.
    ///
    /// - Parameters:
    ///    - data: Входные данные ноды.
    ///    - logContext: Контекст логов.
    func process(_ data: Input) {
        process(data, logContext: LoggingContext())
    }
    
    /// Publisher, возвращаюий результаты на главной очереди.
    var nodeResultPublisher: AnyPublisher<NodeResult<Output>, Never> {
        return nodeResultPublisher(on: DispatchQueue.main)
    }
}

/// Содержит синтаксический сахар для работы с узлами, у которых входящий тип = `Void`
public extension CombineStreamNode where Input == Void {
    
    /// Вызывает `process(_:)`
    func process() {
        return process(Void())
    }
}
