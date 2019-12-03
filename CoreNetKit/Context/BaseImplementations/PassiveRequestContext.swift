//
//  RequestContext.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import CoreEvents

/// Base implementation of `PassiveContext`
public class PassiveRequestContext<Model>: PassiveContext<Model> {

    // MARK: - Typealiases

    public typealias ResultType = Model
    public typealias CompletedClosure = (ResultType) -> Void
    public typealias ErrorClosure = (Error) -> Void

    // MARK: - Private fields

    private var completedEvents: Event<ResultType>
    private var errorEvents: Event<Error>

    // MARK: - Context methods

    /// Initialize context.
    ///
    /// Allows you to specialize type of completed and error events.
    /// Use this initializer to customize events emitting behaviour.
    ///
    /// - Parameters:
    ///   - request: Server request
    ///   - completedEvents: Your custom-type event that contains `onCompleted` listners
    ///   - errorEvents: Your custom-type event that contains `onError` listners
    public init(completedEvents: Event<ResultType> = PresentEvent<ResultType>(), errorEvents: Event<Error> = PresentEvent<Error>()) {
        self.completedEvents = completedEvents
        self.errorEvents = errorEvents
        super.init()
    }

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

    open override func performComplete(result: ResultType) {
        self.completedEvents.invoke(with: result)
    }

    open override func performError(error: Error) {
        self.errorEvents.invoke(with: error)
    }

    #if DEBUG

    deinit {
        print("RequestContext DEINIT")
    }

    #endif
}