//
//  AsyncContext.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

class AsyncContext<Model>: Context<Model> {
    private var dispatchQueue: DispatchQueue = DispatchQueue.main

    @discardableResult
    override func onCompleted(_ closure: @escaping (Model) -> Void) -> Self {
        self.dispatchQueue.async {
            super.onCompleted(closure)
        }
        return self
    }

    @discardableResult
    override func onError(_ closure: @escaping (Error) -> Void) -> Self {
        self.dispatchQueue.async {
            super.onError(closure)
        }
        return self
    }

    @discardableResult
    override func `defer`(_ closure: @escaping () -> Void) -> Self {
        self.dispatchQueue.async {
            super.defer(closure)
        }
        return self
    }

    @discardableResult
    override func emit(data: Model) -> Self {
        self.dispatchQueue.async {
            super.emit(data: data)
        }
        return self
    }

    @discardableResult
    override func emit(error: Error) -> Self {
        self.dispatchQueue.async {
            super.emit(error: error)
        }
        return self
    }
}

extension AsyncContext {
    
    @discardableResult
    func on(_ queue: DispatchQueue) -> Self {
        self.dispatchQueue = queue
        return self
    }
}
