//
//  CoreNetKitTests.swift
//  CoreNetKitTests
//
//  Created by Александр Кравченков on 09.05.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import XCTest
import CoreEvents

@testable import CoreNetKit

class TestSuccessContext: PassiveRequestContext<Void>, PerformableContext, SafeErrorContext {

    func onAccessError(_ completion: @escaping () -> Void) -> Self {
        return self
    }

    func performAccessError() { }

    @discardableResult
    func perform() -> Self {
        super.performComplete(result: ())
        return self
    }
}

class TestErrorContext: PassiveRequestContext<Void>, PerformableContext, SafeErrorContext {

    func onAccessError(_ completion: @escaping () -> Void) -> Self {
        return self
    }

    func performAccessError() { }

    @discardableResult
    func perform() -> Self {
        super.performError(error: NSError())
        return self
    }
}

class TestAccessDeniedContext: PassiveRequestContext<Void>, PerformableContext, SafeErrorContext {

    var accessErrorCompletion: (() -> Void)?

    func onAccessError(_ completion: @escaping () -> Void) -> Self {
        self.accessErrorCompletion = completion
        return self
    }

    func performAccessError() {
        super.performError(error: NSError())
    }

    @discardableResult
    func perform() -> Self {
        self.accessErrorCompletion?()
        return self
    }
}

class AccessSafeContextManagerTest: XCTestCase {

    // MARK: - RefreshAccessContextProvider mocks

    struct PrividerSuccessMock: RefreshAccessContextProvider {
        func getContext() -> ActionableContext<Void> {
            let context = PassiveRequestContext<Void>(completedEvents: PresentEvent<Void>(), errorEvents: PresentEvent<Error>())
            context.performComplete(result: ())

            return context
        }
    }

    struct PrividerFailedMock: RefreshAccessContextProvider {
        func getContext() -> ActionableContext<Void> {
            let context = PassiveRequestContext<Void>(completedEvents: PresentEvent<Void>(), errorEvents: PresentEvent<Error>())
            context.performError(error: NSError())

            return context
        }
    }

    // MARK: - Supports

    private var successContextProvider: AccessSafeContext & ActionableContext<Void> {
        return TestSuccessContext()
    }

    private var badAccessContextProvider: AccessSafeContext & ActionableContext<Void> {
        return TestAccessDeniedContext()
    }

    private var failedContextProvider: AccessSafeContext & ActionableContext<Void> {
        return TestErrorContext()
    }

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Tests

    /// This method test workflow completed for context that complete without access errors (normal case)
    func testThatWorkflowWorksSuccessForCorrectRequest() {

        // Arrange

        let expectation = XCTestExpectation(description: #function)
        let manager = AccessSafeContextManager(refreshAccessContextProvider: PrividerSuccessMock())
        let context = self.successContextProvider

        // Act

        context.onCompleted {
            expectation.fulfill()
        }

        manager.add(context: context)

        wait(for: [expectation], timeout: 5.0)
    }

    /// This method test workflow completed for context that complete with access error (case of access token is expired)
    func testThatWorkflowWorksSuccessForBadAccessRequest() {

        // Arrange

        let expectation = XCTestExpectation(description: #function)
        let manager = AccessSafeContextManager(refreshAccessContextProvider: PrividerFailedMock())
        let context = self.failedContextProvider

        // Act

        context.onError { _ in
            expectation.fulfill()
        }

        manager.add(context: context)

        wait(for: [expectation], timeout: 5.0)
    }

    /// This method test workflow completed for context that complete with any no access error (case of logical error)
    func testThatWorkflowWorksSuccessForBadRequest() {

        // Arrange

        let expectation = XCTestExpectation(description: #function)
        let manager = AccessSafeContextManager(refreshAccessContextProvider: PrividerSuccessMock())
        let context = self.failedContextProvider

        // Act

        context.onError { _ in
            expectation.fulfill()
        }

        manager.add(context: context)

        wait(for: [expectation], timeout: 5.0)
    }
}
