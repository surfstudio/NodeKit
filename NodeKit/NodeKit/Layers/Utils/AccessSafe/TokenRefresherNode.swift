//
//  TokenRefresherNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 06/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Узел для обновления токена и заморозки запросов.
/// Внутри себя работает на приватных очередях.
/// Ответ возращает в той очереди, из которой узел был вызыван.
open class TokenRefresherNode: AsyncNode {

    /// Актор для обновления токена.
    private let tokenRefresherActor: TokenRefresherActorProtocol

    /// Инициаллизирует
    ///
    /// - Parameter tokenRefreshChain: Цепочка для обновления токена.
    public init(tokenRefreshChain: any AsyncNode<Void, Void>) {
        self.tokenRefresherActor = TokenRefresherActor(tokenRefreshChain: tokenRefreshChain)
    }
    
    /// Инициаллизирует
    ///
    /// - Parameter tokenRefresherActor: Актор для обновления токена.
    public init(tokenRefresherActor: TokenRefresherActorProtocol) {
        self.tokenRefresherActor = tokenRefresherActor
    }

    /// Проверяет, был ли отправлен запрос на обновление токена
    /// Если запрос был отправлен, то создает `Observer`, сохраняет его у себя и возвращает предыдущему узлу.
    /// Если нет - отправляет запрос и сохраняет `Observer`
    /// После того как запрос на обновление токена был выполнен успешно - эмитит данные во все сохраненные Observer'ы и удаляет их из памяти
    open func process(
        _ data: Void,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Void> {
        return await tokenRefresherActor.refresh(logContext: logContext)
    }
}