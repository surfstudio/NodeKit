//
//  Context.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

class Context<Model>: Observable, DefaultInitable {
    private var completedClosure: ((Model) -> Void)?
    private var errorClosure: ((Error) -> Void)?
    private var deferClosure: (() -> Void)?

    private var lastEmitedData: Model?
    private var lastEmitedError: Error?

    private var dispatchQueue: DispatchQueue = DispatchQueue.main

    required init() { }

    @discardableResult
    func onCompleted(_ closure: @escaping (Model) -> Void) -> Self {
        
        self.completedClosure = closure
        if let lastEmitedData = self.lastEmitedData {
            self.completedClosure?(lastEmitedData)
            self.lastEmitedData = nil
        }

        return self
    }

    @discardableResult
    func onError(_ closure: @escaping (Error) -> Void) -> Self {

        self.errorClosure = closure

        if let lastEmitedError = self.lastEmitedError {
            self.errorClosure?(lastEmitedError)
            self.lastEmitedError = nil
        }

        return self
    }

    @discardableResult
    func `defer`(_ closure: @escaping () -> Void) -> Self {
        self.deferClosure = closure
        return self
    }

    @discardableResult
    func emit(data: Model) -> Self {
        self.lastEmitedData = data
        self.completedClosure?(data)
        self.deferClosure?()
        return self
    }

    @discardableResult
    func emit(error: Error) -> Self {
        self.lastEmitedError = error
        self.errorClosure?(error)
        self.deferClosure?()
        return self
    }
}
