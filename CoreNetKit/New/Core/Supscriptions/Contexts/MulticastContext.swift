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
/// Используйте этот контекст только в случае если вы действительно понимаете что вы делаете.
open class MulticastContext<Input>: Observer<Input> {

    // MARK: - Field

    private var eventOnCompleted: PresentEvent<Input>
    private var eventOnError: PresentEvent<Error>
    private var eventDefer: PresentEvent<Void>

    // MARK: - Lifecycle

    public override init() {
        self.eventOnCompleted = PresentEvent()
        self.eventOnError = PresentEvent()
        self.eventDefer = PresentEvent()
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

    @discardableResult
    open override func onCompleted(_ closure: @escaping (Input) -> Void) -> Self {
        self.eventOnCompleted += closure
        return self
    }

    @discardableResult
    open override func onError(_ closure: @escaping (Error) -> Void) -> Self {
        self.eventOnError += closure
        return self
    }

    @discardableResult
    open override func `defer`(_ closure: @escaping () -> Void) -> Self {
        self.eventDefer += closure
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
}
