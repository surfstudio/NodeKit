//
//  Context+Operations.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

extension Context {
    func map<T>(_ mapper: @escaping (Model) -> T) -> Context<T> {
        let result = Context<T>()

        self.onCompleted { (model) in
            result.emit(data: mapper(model))
        }

        self.onError { (error) in
            result.emit(error: error)
        }

        return result
    }

    func flatMap<T>(_ mapper: @escaping (Model) -> Context<T>) -> Context<T> {
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

    func combine<T>(_ context: Context<T>) -> Context<(Model, T)> {
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

    func combine<T>(_ contextProvider: @escaping (Model) -> Context<T>) -> Context<(Model, T)> {
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

    func async() -> Context<Model> {
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
