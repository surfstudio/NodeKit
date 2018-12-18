//
//  Context+Operations.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

public extension Context {

    /// Преобразует тип данных контекста из одного в другой.
    /// Аналог `Sequence.map{}`
    /// Для преобразоания необходмо передать замыкание, реализующее преобразования из типа A в тип B
    public func map<T>(_ mapper: @escaping (Model) throws -> T) -> Context<T> {
        let result = Context<T>()

        self.onCompleted { (model) in

            do {
                let data = try mapper(model)
                result.emit(data: data)
            } catch {
                result.emit(error: error)
            }
        }

        self.onError { (error) in
            result.emit(error: error)
        }

        return result
    }

    /// Принцип работы аналогичен `map`, но для работы необходимо передать замыкание, которое возвращает контекст
    public func flatMap<T>(_ mapper: @escaping (Model) -> Context<T>) -> Context<T> {
        let result = Context<T>()

        self.onCompleted { (model) in
            let context = mapper(model)
            context.onCompleted { result.emit(data: $0) }
            context.onError { result.emit(error: $0) }
        }

        self.onError { (error) in
            result.emit(error: error)
        }

        return result
    }

    /// Позволяет комбинировать несколько контекстов в один.
    /// Тогда подписчик будет оповещен только после того,как выполнятся оба контекста.
    public func combine<T>(_ context: Context<T>) -> Context<(Model, T)> {
        let result = Context<(Model, T)>()

        self.onCompleted { (model) in
            context.onCompleted { result.emit(data: (model, $0))}
            context.onError { result.emit(error: $0) }
        }

        self.onError { (error) in
            result.emit(error: error)
        }

        return result
    }

    /// Аналогично `combine<T>(_ context: Context<T>)`, только принимает не контекст, а функцию, которая возвращает контекст
    public func combine<T>(_ contextProvider: @escaping (Model) -> Context<T>) -> Context<(Model, T)> {
        let result = Context<(Model, T)>()

        self.onCompleted { (model) in
            let context = contextProvider(model)
            context.onCompleted { result.emit(data: (model, $0))}
            context.onError { result.emit(error: $0) }
        }

        self.onError { (error) in
            result.emit(error: error)
        }

        return result
    }

    /// Выполняет контекст асинхронно
    public func async() -> Context<Model> {
        let result = AsyncContext<Model>()

        self.onCompleted {
            result.emit(data: $0)

        }
        self.onError {
            result.emit(error: $0)
            
        }

        return result
    }
}
