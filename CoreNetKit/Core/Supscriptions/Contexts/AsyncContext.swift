//
//  AsyncContext.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Асинхронная имплементация `Context`
/// Позволяет устанваливать `DispatchQueue` на которой необходимо вызывать callback подписки.
/// По-умолчанию все диспатчится на DispatchQueue.main
open class AsyncContext<Model>: Context<Model> {

    private var dispatchQueue: DispatchQueue = DispatchQueue.main

    /// Используется для подписки на событие об успешного выполнения.
    @discardableResult
    override open func onCompleted(_ closure: @escaping (Model) -> Void) -> Self {
        self.dispatchQueue.async {
            super.onCompleted(closure)
        }
        return self
    }

    /// Исользуется для подписки на событие о какой-либо ошибки
    @discardableResult
    override open func onError(_ closure: @escaping (Error) -> Void) -> Self {
        self.dispatchQueue.async {
            super.onError(closure)
        }
        return self
    }

    /// Используется для подписки на любой исход события. То есть, вне зависимости от того, была ошибка или успех - эта подписка оповестит подписчика о том, что событие произошло.
    /// Аналог finally в try-catch
    @discardableResult
    override open func `defer`(_ closure: @escaping () -> Void) -> Self {
        self.dispatchQueue.async {
            super.defer(closure)
        }
        return self
    }

    /// Используется для подписку на отмену операции.
    @discardableResult
    override open func onCanceled(_ closure: @escaping () -> Void) -> Self {
        self.dispatchQueue.async {
            super.onCanceled(closure)
        }
        return self
    }

    /// Вызывает оповещение подписчиков о том, что событие выполнилось.
    ///
    /// - Parameter data: Результат события
    @discardableResult
    override open func emit(data: Model) -> Self {
        self.dispatchQueue.async {
            super.emit(data: data)
        }
        return self
    }

    /// Вызывает оповещение подписчиков о том, что произошла ошибка.
    ///
    /// - Parameter error: Произошедшая ошибка
    @discardableResult
    override open func emit(error: Error) -> Self {
        self.dispatchQueue.async {
            super.emit(error: error)
        }
        return self
    }

    /// Отмена действия
    @discardableResult
    override open func cancel() -> Self {
        self.dispatchQueue.async {
            super.cancel()
        }
        return self
    }

    /// Устанавливает `DispatchQueue`
    ///
    /// - Parameter queue: Очередь для диспатчеризации
    @discardableResult
    open func on(_ queue: DispatchQueue) -> Self {
        self.dispatchQueue = queue
        return self
    }
}
