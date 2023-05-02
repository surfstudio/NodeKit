//
//  Context+Operations.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

public extension Observer {

    /// Для обработки ошибки с кастомным типом
    /// **ВАЖНО**: Использовать перед вызовом .onError
    /// **ВАЖНО**: метод defer не дергается при использовании catchError
    func catchError<Type: Error>(_ closure: @escaping (Type) -> Void) -> Observer<Model> {
        let observer = Context<Model>()

        self.onError { error in
            guard
                let casted = error as? Type
            else {
                observer.emit(error: error)
                return
            }
            closure(casted)
        }.onCompleted {
            observer.emit(data: $0)
        }.onCanceled {
            observer.cancel()
        }

        return observer
    }

    /// Позволяет изменить процесс обработки в случае ошибки.
    /// Этот метод позволяет конвертировать возникшую ошибку в другую модель.
    /// Например если в случае ошибки операции мы хотим выполнить другую операцию
    /// и все равно получить результат, то этот метод должен подойти.
    func mapError(_ mapper: @escaping (Error) throws -> Observer<Model>) -> Observer<Model> {
        let result = Context<Model>().log(self.log)
        self.onCompleted { [weak self] model in
            result.log(self?.log).emit(data: model)
        }.onError { [weak self] error in
            do {
                let cntx = try mapper(error)
                cntx.onCompleted { result.log(self?.log).emit(data: $0) }
                cntx.onError { result.log(self?.log).emit(error: $0) }
                cntx.onCanceled { result.log(self?.log).cancel() }
            } catch {
                result.log(self?.log).emit(error: error)
            }
        }.onCanceled { [weak self] in
            result.log(self?.log).cancel()
        }

        return result
    }

    /// Позволяет конвертировать одну ошибку в другую.
    func mapError(_ mapper: @escaping(Error) -> Error) -> Observer<Model> {
        let result = Context<Model>()

        self.onCompleted { [weak self] data in
            result.log(self?.log).emit(data: data)
        }.onError { [weak self] error in
            result.log(self?.log).emit(error: mapper(error))
        }.onCanceled { [weak self] in
            result.log(self?.log).cancel()
        }

        return result
    }

    /// Преобразует тип данных контекста из одного в другой.
    /// Аналог `Sequence.map{}`
    /// Для преобразоания необходмо передать замыкание, реализующее преобразования из типа A в тип B
    func map<T>(_ mapper: @escaping (Model) throws -> T) -> Observer<T> {
        let result = Context<T>()

        self.onCompleted { [weak self] (model) in
            result.log(self?.log)
            do {
                let data = try mapper(model)
                result.emit(data: data)
            } catch {
                result.emit(error: error)
            }
        }.onError { [weak self] (error) in
            result.log(self?.log).emit(error: error)
        }.onCanceled { [weak self] in
            result.log(self?.log).cancel()
        }

        return result
    }

    /// Принцип работы аналогичен `map`, но для работы необходимо передать замыкание, которое возвращает контекст
    func map<T>(_ mapper: @escaping (Model) -> Observer<T>) -> Observer<T> {
        let result = Context<T>()

        self.onCompleted { [weak self] (model) in
            let context = mapper(model)
            context.log(self?.log)
                .onCompleted { [weak context] data in
                    result.log(context?.log).emit(data: data)
                }.onError {  [weak context] error in
                    result.log(context?.log).emit(error: error)
                }.onCanceled { [weak context] in
                    result.log(context?.log).cancel()
                }
        }.onError { [weak self] (error) in
            result.log(self?.log).emit(error: error)
        }.onCanceled { [weak self] in
            result.log(self?.log).cancel()
        }

        return result
    }

    /// Используется для комбинирования нескольких запросов
    /// В отличие от `combine`, если один из ответов вернул ошибку, вызывается `onCompleted`
    /// `onError` вызывается только, если для всех запросов вернулась ошибка
    func combineTolerance<T>(_ provider: @escaping @autoclosure () -> Observer<T>) -> Observer<(Model?, T?)> {
        let result = Context<(Model?, T?)>()
        let successBody = { [weak self] (model: Model?) -> Void in
            let context = provider()
            context.log(self?.log)
                .onCompleted { [weak context] in
                    result.log(context?.log).emit(data: (model, $0))
                }.onError { [weak context] in
                    if model == nil {
                        result.log(context?.log).emit(error: $0)
                    } else {
                        result.log(context?.log).emit(data: (model, nil))
                    }
                }.onCanceled { [weak context] in
                    result.log(context?.log).cancel()
                }
        }
        self.onCompleted { (model) in
            successBody(model)
        }.onError { (error) in
            successBody(nil)
        }.onCanceled { [weak self] in
           result.log(self?.log).cancel()
        }
        return result
    }

    /// Позволяет комбинировать несколько контекстов в один.
    /// Тогда подписчик будет оповещен только после того,как выполнятся оба контекста.
    func combine<T>(_ provider: @escaping @autoclosure () -> Observer<T>) -> Observer<(Model, T)> {
        let result = Context<(Model, T)>()

        self.onCompleted { [weak self] (model) in
            let context = provider()
            context.log(self?.log)
                .onCompleted { [weak context] in
                    result.log(context?.log).emit(data: (model, $0))
                }.onError { [weak context] in
                    result.log(context?.log).emit(error: $0)
                }.onCanceled { [weak context] in
                    result.log(context?.log).cancel()
                }
        }.onError { [weak self] (error) in
            result.log(self?.log).emit(error: error)
        }.onCanceled { [weak self] in
            result.log(self?.log).cancel()
        }

        return result
    }

    /// Выполняет операцию, аналогичную операции `filter` для массивов.
    /// Вызывает для каждого элемента Model predicate
    /// Если predicate возвращает true, то элемент добавлятеся в результирующую коллекцию
    func filter<T>(_ predicate: @escaping (T) -> Bool) -> Observer<Model> where Model == [T] {
        let result = Context<Model>()

        self.onCompleted { [weak self] model in
            result.log(self?.log).emit(data: model.filter { predicate($0) })
        }.onError { [weak self]  (error) in
            result.log(self?.log).emit(error: error)
        }.onCanceled { [weak self] in
            result.log(self?.log).cancel()
        }

        return result
    }

    /// Позволяет "сцепить" два цонтекста вместе так, что данные полученные от каждого контекста сохраняются в результирующем.
    /// Например, если мы делаем Context<A> chain Context<B> то в итоге получается Context(A,B)>
    /// но при этом есть возможность выполнить Context<B> с результатом Context<A>
    ///
    /// - Parameter contextProvider: Что-то что сможет создать контекст, используя результат текущего контекста
    /// - Returns: Комбинированный результат
    func chain<T>(with contextProvider: @escaping (Model) -> Observer<T>?) -> Observer<(Model, T)> {

        let newContext = Context<(Model, T)>()

        self.onCompleted { [weak self] model in

            let context = contextProvider(model)
            context?.log(self?.log)

            context?.onCompleted { [weak context] newModel in
                newContext.log(context?.log).emit(data: (model, newModel))
            }.onError { [weak context] error in
                newContext.log(context?.log).emit(error: error)
            }.onCanceled { [weak context] in
                newContext.log(context?.log).cancel()
            }
        }.onError { [weak self] error in
            newContext.log(self?.log).emit(error: error)
        }.onCanceled { [weak self] in
            newContext.log(self?.log).cancel()
        }

        return newContext
    }

    /// Слушатель получит сообщение на необходмой очереди
    /// - Parameters
    ///     - queue: Очередь, на которой необходимо вызывать методы слушателя
    func dispatchOn(_ queue: DispatchQueue) -> Observer<Model> {
        let result = AsyncContext<Model>().on(queue)

        self.onCompleted { [weak self] in
            result.log(self?.log)
                .emit(data: $0)
        }.onError { [weak self] error in
            result.log(self?.log)
                .emit(error: error)
        }.onCanceled { [weak self] in
            result.log(self?.log)
                .cancel()
        }

        return result
    }

    /// Инкапсулирует обычный context в MulticastContext,
    /// что позволяет подписываться однвоременно несколькими объектами на сообщения
    func multicast() -> Observer<Model> {
        let context = MulticastContext<Model>()
        self.onCompleted { [weak self] data in
            context.log(self?.log).emit(data: data)
        }.onError { [weak self] error in
            context.log(self?.log).emit(error: error)
        }.onCanceled { [weak self] in
            context.log(self?.log).cancel()
        }

        return context
    }

    /// Может быть использовано для чтения состояния.
    /// Передает себя в замыкание
    ///
    /// - Parameter observer: Замыкание, в которое передается этот объект.
    func process(_ observer: (Observer) -> Void) -> Self {
        observer(self)
        return self
    }

    /// Отложит выполнение на величину задержки
    /// -  x x o _
    /// **ВНИМАНИЕ**
    /// Если вызывать дважды на одном и том же контексте, то `emit` произойдет дважды.
    /// - Parameters:
    ///     - queue: Очередь, на которой будет обрабатываться задержка
    ///     - delay: Время задержки
    func debounce(on queue: DispatchQueue = .global(qos: .utility),
                  after delay: DispatchTimeInterval) -> Observer<Model> {
        let result = Context<Model>()
        debouncer.run(on: queue, delay: delay) { [weak self] in
            self?.onCompleted { [weak self] in
                result.log(self?.log)
                    .emit(data: $0)
            }.onError { [weak self] error in
                result.log(self?.log)
                    .emit(error: error)
            }.onCanceled { [weak self] in
                result.log(self?.log)
                    .cancel()
            }
        }
        return result
    }

    /// Заблокирует выполнение на величину задержки
    /// - _ o x x
    /// **ВНИМАНИЕ**
    /// Если вызывать дважды на одном и том же контексте, то `emit` произойдет дважды.
    /// - Parameters:
    ///     - time: Время задержки
    func throttle(next time: DispatchTimeInterval) -> Observer<Model> {
        let result = Context<Model>()
        throttler.run(delay: time) { [weak self] in
            self?.onCompleted { [weak self] in
                result.log(self?.log)
                    .emit(data: $0)
            }.onError { [weak self] error in
                result.log(self?.log)
                    .emit(error: error)
            }.onCanceled { [weak self] in
                result.log(self?.log)
                    .cancel()
            }
        }
        return result
    }
}
