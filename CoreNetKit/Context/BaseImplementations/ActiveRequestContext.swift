//
//  BaseActiveRequestContext.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation
import CoreEvents

/// Base implementation `ActionableContext`
public class ActiveRequestContext<Model>: ActionableContext<Model>, CancellableContext {

    // MARK: - Typealiases

    public typealias ResultType = Model
    public typealias CompletedClosure = (ResultType) -> Void
    public typealias ErrorClosure = (Error) -> Void

    // MARK: - Private fields

    fileprivate var completedEvents: Event<ResultType>
    fileprivate var errorEvents: Event<Error>
    fileprivate let request: BaseServerRequest<Model>

    // MARK: - Initializers / Deinitializers

    /// Initialize context.
    ///
    /// Allows you to specialize type of completed and error events.
    /// Use this initializer to customize events emitting behaviour.
    ///
    /// - Parameters:
    ///   - request: Server request
    ///   - completedEvents: Your custom-type event that contains `onCompleted` listners. **By default** `PresentEvent`
    ///   - errorEvents: Your custom-type event that contains `onError` listners. **By default** `PresentEvent`
    public required init(request: BaseServerRequest<Model>, completedEvents: Event<ResultType> = PresentEvent<ResultType>(), errorEvents: Event<Error> = PresentEvent<Error>()) {
        self.request = request
        self.completedEvents = completedEvents
        self.errorEvents = errorEvents
    }

    #if DEBUG

    deinit {
        print("ActiveRequestContext DEINIT")
    }

    #endif

    // MARK: - Context methods

    @discardableResult
    open override func onCompleted(_ closure: @escaping CompletedClosure) -> Self {
        self.completedEvents += closure
        return self
    }

    @discardableResult
    open override func onError(_ closure: @escaping ErrorClosure) -> Self {
        self.errorEvents += closure
        return self
    }

    @discardableResult
    open func perform() -> Self {
        self.request.performAsync { self.performHandler(result: $0) }
        return self
    }

    @discardableResult
    open func cancel() -> Self {
        self.request.cancel()
        return self
    }

    @discardableResult
    open func safePerform(manager: AccessSafeManager) -> Self {
        let request = ServiceSafeRequest(request: self.request) { self.performHandler(result: $0) }
        manager.addRequest(request: request)
        return self
    }

    func performHandler(result: ResponseResult<Model>) {
        switch result {
        case .failure(let error):
            self.errorEvents.invoke(with: error)
        case .success(let value, _):
            self.completedEvents.invoke(with: value)
        }
    }
}

public class BaseCacheableContext<Model>: ActiveRequestContext<Model>, CacheableContextProtocol {

    public typealias ResultType = Model

    fileprivate var completedCacheEvent: PresentEvent<ResultType>

    /// Initialize context.
    ///
    /// Allows you to specialize type of completed and error events.
    /// Use this initializer to customize events emitting behaviour.
    /// **You can't specialize** `onCacheCompleted`. **It has** `PresentEvent` **emiter type.**
    ///
    /// - Parameters:
    ///   - request: Server request
    ///   - completedEvents: Your custom-type event that contains `onCompleted` listners. **By default** `PresentEvent`
    ///   - errorEvents: Your custom-type event that contains `onError` listners. **By default** `PresentEvent`
    public required init(request: BaseServerRequest<Model>, completedEvents: Event<ResultType> = PresentEvent<ResultType>(), errorEvents: Event<Error> = PresentEvent<Error>()) {
        self.completedCacheEvent = PresentEvent<ResultType>()
        super.init(request: request, completedEvents: completedEvents, errorEvents: errorEvents)
    }

    @discardableResult
    open func onCacheCompleted(_ closure: @escaping (ResultType) -> Void) -> Self {
        self.completedCacheEvent += closure
        return self
    }

    override func performHandler(result: ResponseResult<Model>) {
        switch result {
        case .failure(let error):
            self.errorEvents.invoke(with: error)
        case .success(let value, let cacheFlag):
            DispatchQueue.main.async {
                if cacheFlag {
                    self.completedCacheEvent.invoke(with: value)
                } else {
                    self.completedCacheEvent.eraseLastEmited()
                    self.completedEvents.invoke(with: value)
                }
            }
        }
    }

    @discardableResult
    override open func perform() -> Self {
        self.request.performAsync { [weak self] result in
            self?.performHandler(result: result)
        }
        return self
    }
}
