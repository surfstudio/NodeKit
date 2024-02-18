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
@available(iOS 13.0, *)
open class TokenRefresherNode: Node<Void, Void> {

    /// Цепочка для обновления токена.
    public var tokenRefreshChain: Node<Void, Void>
    private var tokenRefresherActor: TokenRefresherActor

    private var isRequestSended = false
    private var observers: [Context<Void>]

    private let arrayQueue = DispatchQueue(label: "TokenRefresherNode.observers")
    private let flagQueue = DispatchQueue(label: "TokenRefresherNode.flag")

    /// Иницицаллизирует
    ///
    /// - Parameter tokenRefreshChain: Цепочка для обновления токена.
    public init(tokenRefreshChain: Node<Void, Void>) {
        self.tokenRefreshChain = tokenRefreshChain
        self.tokenRefresherActor = TokenRefresherActor(tokenRefreshChain: tokenRefreshChain)
        self.observers = []
    }

    /// Проверяет, был ли отправлен запрос на обновление токена
    /// Если запрос был отправлен, то создает `Observer`, сохраняет его у себя и возвращает предыдущему узлу.
    /// Если нет - отплавляет запрос и сохраняет `Observer`
    /// После того как запрос на обновление токена был выполнен успешно - эмитит данные во все сохраненные Observer'ы и удаляет их из памяти
    open override func process(_ data: Void) async -> Result<Void, Error> {
        if let task = await tokenRefresherActor.task {
            return await task.value
        }
        return await tokenRefresherActor.refresh()
    }
}
