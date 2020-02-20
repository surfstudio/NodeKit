//
//  Context.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Самый обычный контекст, который покрывает большинство случаев использования.
/// Следует всегда использовтаь именно его. 
open class Context<Model>: Observer<Model> {

    // MARK: - Private fileds

    private var completedClosure: ((Model) -> Void)?
    private var errorClosure: ((Error) -> Void)?
    private var deferClosure: (() -> Void)?
    private var cancelClosure: (() -> Void)?

    private var lastEmitedData: Model?
    private var lastEmitedError: Error?

    private var needCallDefer = false

    private var dispatchQueue: DispatchQueue = DispatchQueue.main

    public override init() { }

    /// Используется для подписки на событие об успешного выполнения.
    @discardableResult
    open override func onCompleted(_ closure: @escaping (Model) -> Void) -> Self {
        
        self.completedClosure = closure
        if let lastEmitedData = self.lastEmitedData {
            self.completedClosure?(lastEmitedData)
            self.lastEmitedData = nil
        }

        return self
    }

    /// Исользуется для подписки на событие о какой-либо ошибке
    @discardableResult
    open override func onError(_ closure: @escaping (Error) -> Void) -> Self {

        self.errorClosure = closure

        if let lastEmitedError = self.lastEmitedError {
            self.errorClosure?(lastEmitedError)
            self.lastEmitedError = nil
        }

        return self
    }

    /// Используется для подписку на отмену операции.
    @discardableResult
    open override func onCanceled(_ closure: @escaping () -> Void) -> Self {
        self.cancelClosure = closure
        return self
    }

    /// Используется для подписки на любой исход события. То есть, вне зависимости от того, была ошибка или успех - эта подписка оповестит подписчика о том, что событие произошло.
    /// Аналог finally в try-catch
    @discardableResult
    open override func `defer`(_ closure: @escaping () -> Void) -> Self {
        self.deferClosure = closure

        if self.needCallDefer {
            self.deferClosure?()
            self.needCallDefer = false
        }
        
        return self
    }

    /// Вызывает оповещение подписчиков о том, что событие выполнилось.
    ///
    /// - Parameter data: Результат события
    @discardableResult
    open func emit(data: Model) -> Self {
        self.lastEmitedData = data
        self.lastEmitedError = nil
        self.completedClosure?(data)
        self.deferClosure?()
        self.needCallDefer = true
        return self
    }

    /// Вызывает оповещение подписчиков о том, что произошла ошибка.
    ///
    /// - Parameter error: Произошедшая ошибка
    @discardableResult
    open func emit(error: Error) -> Self {
        self.lastEmitedError = error
        self.lastEmitedData = nil
        self.errorClosure?(error)
        self.deferClosure?()
        self.needCallDefer = true
        return self
    }

    /// Отмена действия
    /// - Warning: Затирает всех подписчиков
    @discardableResult
    open override func cancel() -> Self {
        self.cancelClosure?()
        self.deferClosure?()
        self.completedClosure = nil
        self.errorClosure = nil
        return self
    }

    /// Удаляет сулушателей у данного экземпляра контекста. 
    open override func unsubscribe() {
        self.errorClosure = nil
        self.cancelClosure = nil
        self.completedClosure = nil
        self.deferClosure = nil
    }
}
