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

    @discardableResult
    override open func onCompleted(_ closure: @escaping (Model) -> Void) -> Self {
        self.dispatchQueue.async {
            super.onCompleted(closure)
        }
        return self
    }

    @discardableResult
    override open func onError(_ closure: @escaping (Error) -> Void) -> Self {
        self.dispatchQueue.async {
            super.onError(closure)
        }
        return self
    }

    @discardableResult
    override open func `defer`(_ closure: @escaping () -> Void) -> Self {
        self.dispatchQueue.async {
            super.defer(closure)
        }
        return self
    }

    @discardableResult
    override open func emit(data: Model) -> Self {
        self.dispatchQueue.async {
            super.emit(data: data)
        }
        return self
    }

    @discardableResult
    override open func emit(error: Error) -> Self {
        self.dispatchQueue.async {
            super.emit(error: error)
        }
        return self
    }
}

extension AsyncContext {

    /// Устанавливает `DispatchQueue`
    ///
    /// - Parameter queue: Очередь для диспатчеризации
    @discardableResult
    open func on(_ queue: DispatchQueue) -> Self {
        self.dispatchQueue = queue
        return self
    }
}
