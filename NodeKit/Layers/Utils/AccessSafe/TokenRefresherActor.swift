//
//  TokenRefresherActor.swift
//  NodeKit
//
//  Created by frolov on 20.03.2024.
//  Copyright © 2024 Surf. All rights reserved.
//

/// Протокол актора обновления токена
public protocol TokenRefresherActorProtocol: Actor {
    /// Возвращает результат обновления токена.
    /// Если процесс был запущен, ждет и возвращает результат предыдущего запроса
    ///
    /// - Parameter logContext: контекст для записи логов
    /// - Returns результат обновления токена
    func refresh(logContext: LoggingContextProtocol) async -> NodeResult<Void>
}

/// Релизация протокола актора для создания таски обновления токена
actor TokenRefresherActor: TokenRefresherActorProtocol {

    // MARK: - Private Properties
    
    /// Текущая таска обновления токена
    private var task: Task<NodeResult<Void>, Never>?
    
    /// Цепочка нод, которые обновляют токен
    private var tokenRefreshChain: any AsyncNode<Void, Void>
    
    // MARK: - Initialization

    init(tokenRefreshChain: some AsyncNode<Void, Void>) {
        self.tokenRefreshChain = tokenRefreshChain
    }
    
    // MARK: - Methods

    /// Возвращает результат обновления токена.
    /// Если процесс был запущен, ждет и возвращает результат предыдущего запроса
    ///
    /// - Parameter logContext: контекст для записи логов
    /// - Returns результат обновления токена
    func refresh(logContext: LoggingContextProtocol) async -> NodeResult<Void> {
        guard let task = task else {
            return await resultFromNewTask(logContext: logContext)
        }
        return await task.value
    }
    
    private func resultFromNewTask(logContext: LoggingContextProtocol) async -> NodeResult<Void> {
        let refreshTask = Task {
            return await tokenRefreshChain.process((), logContext: logContext)
        }
        task = refreshTask
        let value = await refreshTask.value
        task = nil
        return value
    }
}
