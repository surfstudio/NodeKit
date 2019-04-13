//
//  Observable.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Протокол для объектов, которые имеют инициаллизатор по-умолчанию
public protocol DefaultInitable {
    init()
}

/// Протокол для реализации модели подписки.
/// Описывает объект, который наблюдает за каким-то событием и когда оно происходит - сообщает подписчикам о том, что собтие произошло.
/// Концептуально схож с Rx Observable
public protocol ObservableProtocol {

    /// Тип данных, которые возвращает событие
    associatedtype Model

    /// Используется для подписки на событие об успешного выполнения.
    @discardableResult
    func onCompleted(_ closure: @escaping (Model) -> Void) -> Self

    /// Исользуется для подписки на событие о какой-либо ошибки.
    @discardableResult
    func onError(_ closure: @escaping (Error) -> Void) -> Self

    /// Используется для подписки на любой исход события. То есть, вне зависимости от того, была ошибка или успех - эта подписка оповестит подписчика о том, что событие произошло.
    /// Аналог finally в try-catch
    @discardableResult
    func `defer`(_ closure: @escaping () -> Void) -> Self
}

/// По сути является Type erasure для `Observable`
open class Observer<Input>: ObservableProtocol {

    public typealias Model = Input

    /// Лог-сообщение.
    public var log: Logable?

    /// Конструткор по-умолчанию.
    public init() { }

    /// Используется для подписки на событие об успешном выполнения операции.
    /// - Warning: Ожидается реализация в потомке. В противном случае приложение крашнется. 
    @discardableResult
    open func onCompleted(_ closure: @escaping (Input) -> Void) -> Self {
        fatalError("Needs to override method \(#function) in \(self.self)")
    }

    /// Исользуется для подписки на событие о какой-либо ошибки
    /// - Warning: Ожидается реализация в потомке. В противном случае приложение крашнется.
    @discardableResult
    open func onError(_ closure: @escaping (Error) -> Void) -> Self {
        fatalError("Needs to override method \(#function) in \(self.self)")
    }

    /// Используется для подписки на любой исход события. То есть, вне зависимости от того, была ошибка или успех - эта подписка оповестит подписчика о том, что событие произошло.
    /// Аналог finally в try-catch
    /// - Warning: Ожидается реализация в потомке. В противном случае приложение крашнется.
    @discardableResult
    open func `defer`(_ closure: @escaping () -> Void) -> Self {
        fatalError("Needs to override method \(#function) in \(self.self)")
    }

    /// Используется для подписку на отмену операции.
    /// - Warning: Ожидается реализация в потомке. В противном случае приложение крашнется.
    @discardableResult
    open func onCanceled(_ closure: @escaping () -> Void) -> Self {
        fatalError("Needs to override method \(#function) in \(self.self)")
    }

    /// Отмена действия
    /// - Warning: Ожидается реализация в потомке. В противном случае приложение крашнется.
    @discardableResult
    open func cancel() -> Self {
        fatalError("Needs to override method \(#function) in \(self.self)")
    }

    /// Удаляет сулшуателей у данного экземпляра контекста.
    open func unsubscribe() {
        fatalError("Needs to override method \(#function) in \(self.self)")
    }

    /// Добавляет лог-сообщение к контексту.
    /// В случае, если у контекста не было лога, то он появится.
    /// В случае, если у контекста был лог, но у него не было следующего, то этот добавится в качестве следующего лога.
    /// В случае, если лог был, а у него был следующий лог, то этот будет вставлен между ними.
    ///
    /// - Parameter log: лог-сообщение.
    @discardableResult
    open func log(_ log: Logable?) -> Self {
        guard var selfLog = self.log else {
            self.log = log
            return self
        }

        if selfLog.next == nil {
            selfLog.next = log
        } else {
            var temp = log
            temp?.next = selfLog.next
            selfLog.next = temp
        }

        self.log = selfLog
        return self
    }

}
