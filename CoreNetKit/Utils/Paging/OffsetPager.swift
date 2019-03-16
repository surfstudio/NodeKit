//
//  Pager.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 10/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Описывает интерфейс сущности, которая позволяет изменять набор данных.
/// Например, в частном случае это может быть итератор.
/// Например `FILE` реализует этот протокол.
/// При открытии файла указатель чтения установлен на 0 символ, а шаг чтения составляет 10 символов.
/// Тогда вызов функции `next()` изменит указатель на `0 + 10`.
public protocol Paginable {

    /// Переключает набор данных на следующий
    @discardableResult
    func next() -> Self
}

/// ## Описание
/// `Observer` реализующий протокол `Paginable`.
/// По свой сути является синхронным пагинатором.
/// Необходимо для работы с пагинируемыми источниками данных, так как инкапсулриует их от читателя и предоставляет последнему привычный интерфейс.
///
/// Особенностью этого `Observer` является возможность подписаться на событие завершения пагинации с помощью метода `AsyncPager.onOver(_:)`.
///
/// - Important:
/// Подписка срабатывать **только** в том случае, если источник данных больше не имеет данных.
///
/// ## Вспомогательная информация
/// - SeeAlso:
///    - Observer
///    - Paginable
open class AsyncPager<Input, Output>: Observer<Output>, Paginable {

    // MARK: - Types

    /// Тип узла, с котором работает этот класс
    ///
    /// SeeAlso:
    /// - `Node`
    /// - Paginable
    public typealias PagingNode = Node<Input, Output> & Paginable

    // MARK: - Fields

    private var onOverClosure: (() -> Void)?

    // MARK: - Properties

    /// Узел, являющийся поставщиком данных.
    /// Очевидно, что сам узел при этом должен быть пагинируемый
    ///
    /// SeeAlso: `AsyncPager.PagingNode`
    public var pagingNode: PagingNode

    // MARK: - Init and deinit

    /// Инициаллизирует объект провайдером данных.
    ///
    /// - Parameter pagingNode: пагинируемый провайдер данных
    public init(pagingNode: PagingNode) {
        self.pagingNode = pagingNode
        super.init()
    }

    // MARK: - Subscription

    /// Подписка на окончание пагинации.
    /// Подписчик будет оповещен в том случае, когда в провайдере данные закончатся.
    /// Конкретную логику завершения пагинации должен имплементировать сам провайцдер.
    open func onOver(_ closure: @escaping () -> Void) -> Self {
        self.onOverClosure = closure
        return self
    }

    // MARK: - Paginable

    /// Передает вызов провайдеру данных
    ///
    /// SeeAlso: `Paginable.next()`
    @discardableResult
    open func next() -> Self {
        _ = self.pagingNode.next()
        return self
    }
}
