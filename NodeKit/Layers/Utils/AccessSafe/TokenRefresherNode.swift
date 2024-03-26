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

    /// Цепочка для обновления токена.
    public var tokenRefreshChain: any AsyncNode<Void, Void> {
        didSet {
            Task {
                await tokenRefresherActor.update(tokenRefreshChain: tokenRefreshChain)
            }
        }
    }
    private var tokenRefresherActor: TokenRefresherActorProtocol

    private var isRequestSended = false
    private var observers: [Context<Void>]

    private let arrayQueue = DispatchQueue(label: "TokenRefresherNode.observers")
    private let flagQueue = DispatchQueue(label: "TokenRefresherNode.flag")

    /// Иницицаллизирует
    ///
    /// - Parameter tokenRefreshChain: Цепочка для обновления токена.
    /// - Parameter tokenRefresherActor: Актор для обновления токена.
    public init(tokenRefreshChain: any AsyncNode<Void, Void>, tokenRefresherActor: TokenRefresherActorProtocol) {
        self.tokenRefreshChain = tokenRefreshChain
        self.tokenRefresherActor = tokenRefresherActor
        self.observers = []
    }
    
    /// Иницицаллизирует
    ///
    /// - Parameter tokenRefreshChain: Цепочка для обновления токена.
    public convenience init(tokenRefreshChain: any AsyncNode<Void, Void>) {
        self.init(tokenRefreshChain: tokenRefreshChain, tokenRefresherActor: TokenRefresherActor(tokenRefreshChain: tokenRefreshChain))
    }

    /// Проверяет, был ли отправлен запрос на обновление токена
    /// Если запрос был отправлен, то создает `Observer`, сохраняет его у себя и возвращает предыдущему узлу.
    /// Если нет - отплавляет запрос и сохраняет `Observer`
    /// После того как запрос на обновление токена был выполнен успешно - эмитит данные во все сохраненные Observer'ы и удаляет их из памяти
    open func process(_ data: Void) -> Observer<Void> {

        let shouldSaveContext: Bool = self.flagQueue.sync {
            if self.isRequestSended {
                return true
            } else {
                self.isRequestSended = true
            }
            return false
        }

        if shouldSaveContext {
            var log = Log(self.logViewObjectName, id: self.objectName)
            return self.arrayQueue.sync {
                log += "Save context to queue"
                let result = Context<Void>()
                self.observers.append(result)
                return result.log(log) 
            }
        }

        return self.tokenRefreshChain.process(()).map { [weak self] model -> Void in

            guard let `self` = self else { return () }

            self.flagQueue.sync { self.isRequestSended = false }

            let observers = self.arrayQueue.sync(execute: { return self.observers })
            observers.forEach { $0.emit(data: ()) }
            self.arrayQueue.async { [weak self] in
                self?.observers.removeAll()
            }
            return ()
        }.mapError { [weak self] error -> Error in
            guard let `self` = self else { return error }

            self.flagQueue.sync { self.isRequestSended = false }

            let observers = self.arrayQueue.sync(execute: { return self.observers })
            observers.forEach { $0.emit(error: error) }
            self.arrayQueue.async { [weak self] in
                self?.observers.removeAll()
            }

            return error
        }
    }

    /// Проверяет, был ли отправлен запрос на обновление токена
    /// Если запрос был отправлен, то создает `Observer`, сохраняет его у себя и возвращает предыдущему узлу.
    /// Если нет - отплавляет запрос и сохраняет `Observer`
    /// После того как запрос на обновление токена был выполнен успешно - эмитит данные во все сохраненные Observer'ы и удаляет их из памяти
    open func process(
        _ data: Void,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Void> {
        return await tokenRefresherActor.refresh(logContext: logContext)
    }
}
