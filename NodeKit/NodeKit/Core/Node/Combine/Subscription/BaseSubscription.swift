//
//  BaseSubscription.swift
//  NodeKit
//
//  Created by Andrei Frolov on 17.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine

/// Абстрактная реализация подписки для любой ``CombineCompatibleNode``.
/// При запросе данных создает новую таску и сохраняет ее.
/// При отмене подписки вызывает cancel у таски.
class BaseSubscription<Parent: NodeResultPublisher, S: NodeSubscriber<Parent.Node>>: Subscription {
    
    // MARK: - Private Properties
    
    private let lock = NSLock()
    
    private var task: Task<(), Never>?
    private var demand = Subscribers.Demand.none
    private var parent: Parent?
    private var subscriber: S?
    
    // MARK: - Initialization
    
    init(parent: Parent, subscriber: S) {
        self.parent = parent
        self.subscriber = subscriber
    }
    
    // MARK: - Subscription
    
    func request(_ demand: Subscribers.Demand) {
        synchronized {
            guard
                demand != .zero,
                task == nil,
                let parent = parent,
                let subscriber = subscriber
            else {
                return
            }
            
            task = synchronizedRunTask(
                node: parent.node,
                input: parent.input,
                logContext: parent.logContext,
                subscriber: subscriber
            )
            self.demand += demand
        }
    }
    
    func cancel() {
        synchronized {
            task?.cancel()
            parent = nil
            subscriber = nil
            demand = .none
            task = nil
        }
    }
    
    // MARK: - Methods
    
    /// Метод создания таски для выполенения обработки данных.
    ///
    /// - Parameters:
    ///    - node: Нода, у которая будет отвечать за обработку данных.
    ///    - input: Воходные данные ноды
    ///    - logContext: Контекст логов.
    ///    - subscriber: Подписчик, который будет получать результат ноды.
    /// - Returns: Созданая таска, выполняющая обработку данных.
    func synchronizedRunTask(
        node: Parent.Node,
        input: Parent.Node.I,
        logContext: LoggingContextProtocol,
        subscriber: S
    ) -> Task<(), Never> {
        fatalError("Override method in subclass")
    }
}

// MARK: - Private Methods

private extension BaseSubscription {
    
    func synchronized(_ function: () -> Void) {
        lock.lock()
        function()
        lock.unlock()
    }
}
