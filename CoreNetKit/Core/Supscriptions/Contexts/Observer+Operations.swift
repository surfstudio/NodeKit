//
//  Context+Operations.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

public extension Observer {

    /// Позволяет изменить процесс обработки в случае ошибки.
    /// Этот метод позволяет конвертировать возникшую ошибку в другую модель.
    /// Например если в случае ошибки операции мы хотим выполнить другую операцию
    /// и все равно получить результат, то этот метод должен подойти.
    public func error(_ mapper: @escaping (Error) throws -> Observer<Model>) -> Observer<Model> {
        let result = Context<Model>()

        self.onCompleted { model in
            result.emit(data: model)
        }.onError { error in
            do {
                let cntx = try mapper(error)
                cntx.onCompleted { result.emit(data: $0) }
                cntx.onError { result.emit(error: $0) }
                cntx.onCanceled { result.cancel() }
            } catch {
                result.emit(error: error)
            }
            result.emit(error: error)
        }.onCanceled {
            result.cancel()
        }

        return result
    }

    /// Преобразует тип данных контекста из одного в другой.
    /// Аналог `Sequence.map{}`
    /// Для преобразоания необходмо передать замыкание, реализующее преобразования из типа A в тип B
    public func map<T>(_ mapper: @escaping (Model) throws -> T) -> Observer<T> {
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
    public func flatMap<T>(_ mapper: @escaping (Model) -> Observer<T>) -> Observer<T> {
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
    public func combine<T>(_ context: Observer<T>) -> Observer<(Model, T)> {
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
    public func combine<T>(_ contextProvider: @escaping (Model) -> Observer<T>) -> Observer<(Model, T)> {
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

    /// Выполняет операцию, аналогичную операции `filter` для массивов.
    /// Вызывает для каждого элемента Model predicate
    /// Если predicate возвращает true, то элемент добавлятеся в результирующую коллекцию
    public func filter<T>(_ predicate: @escaping (T) -> Bool) -> Observer<Model> where Model == [T] {
        let result = Context<Model>()

        self.onCompleted { model in
            result.emit(data: model.filter { predicate($0) })
        }.onError { (error) in
            result.emit(error: error)
        }

        return result
    }

    /// Позволяет "сцепить" два цонтекста вместе так, что данные полученные от каждого контекста сохраняются в результирующем.
    /// Например, если мы делаем Context<A> chain Context<B> то в итоге получается Context(A,B)>
    /// но при этом есть возможность выполнить Context<B> с результатом Context<A>
    ///
    /// - Parameter contextProvider: Что-то что сможет создать контекст, используя результат текущего контекста
    /// - Returns: Комбинированный результат
    public func chain<T>(with contextProvider: @escaping (Model) -> Observer<T>?) -> Observer<(Model, T)> {

        let newContext = Context<(Model, T)>()

        self.onCompleted { model in

            let context = contextProvider(model)

            context?.onCompleted { newModel in
                newContext.emit(data: (model, newModel))
            }.onError { error in
                newContext.emit(error: error)
            }

            }.onError { error in
                newContext.emit(error: error)
        }
        return newContext
    }

    /// Слушатель получит сообщение на необходмой очереди
    /// - Parameters
    ///     - queue: Очередь, на которой необходимо вызывать методы слушателя
    public func dispatchOn(_ queue: DispatchQueue) -> Observer<Model> {
        let result = AsyncContext<Model>().on(queue)

        self.onCompleted {
            result.emit(data: $0)
        }

        self.onError {
            result.emit(error: $0)
        }

        return result
    }

    /// Инкапсулирует обычный context в MulticastContext,
    /// что позволяет подписываться однвоременно несколькими объектами на сообщения
    public func multicast() -> Observer<Model> {
        let context = MulticastContext<Model>()

        self.onCompleted {
            context.emit(data: $0)
        }.onError {
            context.emit(error: $0)
        }

        return context
    }
}
