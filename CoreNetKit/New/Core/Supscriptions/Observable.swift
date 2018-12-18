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
public protocol Observable {

    /// Тип данных, которые возвращает событие
    associatedtype Model

    /// Используется для подписки на событие об успешного выполнения.
    @discardableResult
    func onCompleted(_ closure: @escaping (Model) -> Void) -> Self

    /// Исользуется для подписки на событие о какой-либо ошибки
    @discardableResult
    func onError(_ closure: @escaping (Error) -> Void) -> Self

    /// Используется для подписки на любой исход события. То есть, вне зависимости от того, была ошибка или успех - эта подписка оповестит подписчика о том, что событие произошло.
    /// Аналог finally в try-catch
    @discardableResult
    func `defer`(_ closure: @escaping () -> Void) -> Self
}
