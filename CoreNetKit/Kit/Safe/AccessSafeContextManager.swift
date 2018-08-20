//
//  AccessSafeContextManager.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 09.05.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import CoreEvents

// MARK: - Support types

public protocol PerformableContext: class {

    @discardableResult
    func perform() -> Self
}

public protocol SafeErrorContext: class {

    @discardableResult
    func onAccessError(_ completion: @escaping () -> Void) -> Self
    func performAccessError()
}

public typealias AccessSafeContext = PerformableContext & SafeErrorContext

/// This object should provide contexts that can update access.
public protocol RefreshAccessContextProvider {
    func getContext() -> ActionableContext<Void>
}

// MARK: - Manager

open class AccessSafeContextManager {

    // MARK: - Fileds

    fileprivate var activeContext: [AccessSafeContext]
    fileprivate var isRefreshTokenRequestWasSended: Atomic<Bool>
    fileprivate let semaphore: DispatchSemaphore

    // MARK: - Properties

    public var refreshAccessContextProvider: RefreshAccessContextProvider

    public init(refreshAccessContextProvider: RefreshAccessContextProvider) {
        self.refreshAccessContextProvider = refreshAccessContextProvider
        self.activeContext = [AccessSafeContext]()
        self.semaphore = DispatchSemaphore(value: 1)
        self.isRefreshTokenRequestWasSended = Atomic(value: false)
    }

    public func add(context: AccessSafeContext) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.backgoundAdd(context: context)
        }
    }

    /// Removed all sleeped requests and allows perform new requests
    public func clear() {
        self.activeContext.removeAll()
        self.isRefreshTokenRequestWasSended.write(value: false)
    }

    /// Tried reperform all waiting requests
    public func update() {
        self.successSafePerformation()
    }
}

// MARK: - Backround methods

private extension AccessSafeContextManager {

    func backgoundAdd(context: AccessSafeContext) {

        self.semaphore.wait()

        // true if no need perform
        // false if perform needed
        guard !isRefreshTokenRequestWasSended.read() else {
            self.semaphore.signal()
            return
        }

        self.semaphore.signal()

        self.requestPerformationWrapper(context: context)
    }

    func requestPerformationWrapper(context: AccessSafeContext) {

        context.onAccessError {

            self.activeContext.append(context)

            self.semaphore.wait()

            // true if no need perform
            // false if perform needed
            if self.isRefreshTokenRequestWasSended.read() {
                self.semaphore.signal()
                return
            }

            self.isRefreshTokenRequestWasSended.write(value: true)
            self.semaphore.signal()

            self.safePerform(context: context)
        }

        context.perform()
    }

    private func safePerform(context: AccessSafeContext) {
        self.refreshAccessContextProvider.getContext()
            .onCompleted {
                context.perform()
            }.onError { _ in
                self.failedSafePerformation(context: context)
            }
    }

    private func successPerformation(context: AccessSafeContext) {
        self.semaphore.wait()

        if !self.isRefreshTokenRequestWasSended.read(),
            let index = self.activeContext.index(where: { $0 === context }) {

            self.activeContext.remove(at: index)
        }

        self.semaphore.signal()
    }

    private func failedSafePerformation(context: AccessSafeContext?) {
        context?.performAccessError()
        self.activeContext.removeAll()
        self.isRefreshTokenRequestWasSended.write(value: false)
    }

    func successSafePerformation(context: AccessSafeContext) {
        successPerformation(context: context)
        self.successSafePerformation()
    }

    func successSafePerformation() {
        self.semaphore.wait()

        self.isRefreshTokenRequestWasSended.write(value: false)

        self.semaphore.signal()

        for context in self.activeContext {
            self.requestPerformationWrapper(context: context)
        }
    }

    private func initializeNewPerformation() {
        self.semaphore.wait()

        guard let context = self.activeContext.first else {
            self.semaphore.signal()
            return
        }
        self.semaphore.signal()

        self.requestPerformationWrapper(context: context)
    }
}

