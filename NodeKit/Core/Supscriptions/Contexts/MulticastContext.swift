//
//  MulticastContext.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 03/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import CoreEvents

/// Это контекст, который поддерживает рассылку сообщений одновреенно нескольким слушателям.
/// В качестве event используется CoreEvents
/// - Warning: Используйте этот контекст только в случае если вы действительно понимаете что вы делаете.
open class MulticastContext<Input>: Observer<Input> {

    // MARK: - Field

    private var eventOnCompleted: PresentEvent<Input>
    private var eventOnError: PresentEvent<Error>
    private var eventOnCancelled: PresentEvent<Void>
    private var eventDefer: PresentEvent<Void>

    // MARK: - Lifecycle

    public override init() {
        self.eventOnCompleted = PresentEvent()
        self.eventOnError = PresentEvent()
        self.eventDefer = PresentEvent()
        self.eventOnCancelled = PresentEvent()
    }

    deinit {

        #if DEBUG_DEINIT_CORENETKIT

        withUnsafeBytes(of: self, { pointer in
            print("MulticastContext(\(pointer)) is deinit")
        })

        #endif

        self.eventOnCompleted.clear()
        self.eventOnError.clear()
        self.eventDefer.clear()
    }

    // MARK: - Observable

    /// Добавляет подписчка на успешное выполнение операции.
    @discardableResult
    open override func onCompleted(_ closure: @escaping (Input) -> Void) -> Self {
        self.eventOnCompleted.add(key: UUID().uuidString, closure)
        return self
    }

    /// Дополняет подписчка на завершение операции с ошибкой.
    @discardableResult
    open override func onError(_ closure: @escaping (Error) -> Void) -> Self {
        self.eventOnError.add(key: UUID().uuidString, closure)
        return self
    }

    /// Добавляет подписчка на выполнение операции с любым исходом.
    @discardableResult
    open override func `defer`(_ closure: @escaping () -> Void) -> Self {
        self.eventDefer.add(key: UUID().uuidString, closure)
        return self
    }

    /// Добавляте одписчка на отмену операции.
    @discardableResult
    open override func onCanceled(_ closure: @escaping () -> Void) -> Self {
        self.eventOnCancelled.add(key: UUID().uuidString, closure)
        return self
    }

    // MARK: - Emiters

    /// Вызывает оповещение подписчиков о том, что событие выполнилось.
    ///
    /// - Parameter data: Результат события
    @discardableResult
    open func emit(data: Model) -> Self {
        self.eventOnCompleted.invoke(with: data)
        self.eventDefer.invoke(with: ())
        return self
    }

    /// Вызывает оповещение подписчиков о том, что произошла ошибка.
    ///
    /// - Parameter error: Произошедшая ошибка
    @discardableResult
    open func emit(error: Error) -> Self {
        self.eventOnError.invoke(with: error)
        self.eventDefer.invoke(with: ())
        return self
    }

    //// Оповещает всех слушателей об отмене
    /// - Warning: Удаляет всех слушателей!
    @discardableResult
    open override func cancel() -> Self {
        self.eventOnCancelled.invoke(with: ())
        self.eventOnCompleted.clear()
        self.eventOnError.clear()
        return self
    }

    /// Удаляет сулушателей у данного экземпляра контекста.
    /// - Warning: Удаляет всех слушателей!
    open override func unsubscribe() {
        self.eventDefer.clear()
        self.eventOnError.clear()
        self.eventOnCancelled.clear()
        self.eventOnCompleted.clear()
    }

}
