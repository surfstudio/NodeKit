//
//  TokenRefresherActor.swift
//  NodeKit
//
//  Created by frolov on 20.03.2024.
//  Copyright © 2024 Surf. All rights reserved.
//

/// Token refresh actor protocol.
public protocol TokenRefresherActorProtocol: Actor {
    /// Returns the token refresh result.
    /// If the process was initiated, waits and returns the result of the previous request.
    ///
    /// - Parameter logContext: The context for logging.
    /// - Returns: The token refresh result.
    func refresh(logContext: LoggingContextProtocol) async -> NodeResult<Void>
}

/// Релизация протокола актора для создания таски обновления токена
actor TokenRefresherActor: TokenRefresherActorProtocol {

    // MARK: - Private Properties
    
    /// Current token refresh task.
    private var task: Task<NodeResult<Void>, Never>?
    
    /// Chain of nodes responsible for token refresh
    private var tokenRefreshChain: any AsyncNode<Void, Void>
    
    // MARK: - Initialization

    init(tokenRefreshChain: some AsyncNode<Void, Void>) {
        self.tokenRefreshChain = tokenRefreshChain
    }
    
    // MARK: - Methods

    /// Возвращает результат обновления токена.
    /// Если процесс был запущен, ожидает и возвращает результат предыдущего запроса.
    ///
    /// - Parameter logContext: Контекст для записи логов.
    /// - Returns: Результат обновления токена.
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
