//
//  Context+Shugar.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 03/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

extension Observer {
    /// Вызывает оповещение подписчиков о том, что событие выполнилось.
    /// Создает контекст нужного типа и эмитит объект Model. Является синтаксическим сахаром.
    ///
    /// - Parameter data: Результат события
    @discardableResult
    public static func emit(data: Model) -> Context<Model> {
        return Context<Model>().emit(data: data)
    }

    /// Вызывает оповещение подписчиков о том, что произошла ошибка.
    /// Создает контекст нужного типа и эмитит ошибку. Является синтаксическим сахаром.
    /// Позволяет удобно обрабатывать ситуации, в которых нужно провинуть ошибку. Например:
    /// `
    /// func serviceMehtod() -> Context<Type> {
    ///     let url = Enpdoint.path else {
    ///         return .emit(error: BaseError.urlNotFound)
    ///     }
    /// }
    /// `
    ///
    ///
    /// - Parameter error: Произошедшая ошибка
    @discardableResult
    public static func emit(error: Error) -> Context<Model> {
        return Context<Model>().emit(error: error)
    }
}
