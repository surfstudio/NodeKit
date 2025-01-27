//
//  LoggerNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class LoggerNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<Int, Int>!
    private var logContextMock: LoggingContextMock!
    private var loggingProxyMock: LoggingProxyMock!
    private var urlProviderMock: URLRouteProviderMock!

    // MARK: - Sut
    
    private var sut: LoggerNode<Int, Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        loggingProxyMock = LoggingProxyMock()
        urlProviderMock = URLRouteProviderMock()
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProccess_thenNextCalled() async throws {
        // given
        
        let expectedInput = 00942
        makeSutWithoutLoggingProxy(method: .get)
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(expectedInput, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input, expectedInput)
    }
    
    func testAsyncProccess_whenNextNodeReturnsSuccess_thenSuccessReceived() async throws {
        // given
        
        let expectedResult = 001238
        makeSutWithoutLoggingProxy(method: .get)
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(1, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProccess_whenNextNodeReturnsFailure_thenFailureReceived() async throws {
        // given
        
        makeSutWithoutLoggingProxy(method: .get)
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(1, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .firstError)
    }

    func testAsyncProcess_thenRequestParamsPassed() async throws {
        // given

        makeSutWithoutLoggingProxy(method: .get)
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)

        // when

        let result = await sut.process(1, logContext: logContextMock)

        // then

        let invokedSet = await logContextMock.invokedSet
        let invokedSetCount = await logContextMock.invokedSetCount
        let invokedSetParams = await logContextMock.invokedSetParameter
        let invokedSetURLProvider = try XCTUnwrap(invokedSetParams?.1 as? URLRouteProviderMock)

        XCTAssertTrue(invokedSet)
        XCTAssertEqual(invokedSetCount, 1)
        XCTAssertEqual(invokedSetParams?.0, .get)
        XCTAssert(invokedSetURLProvider === urlProviderMock)
    }

    func testAsyncProcess_thenCompleteCalled() async {
        // given

        makeSutWithoutLoggingProxy(method: .get)
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)

        // when

        let result = await sut.process(1, logContext: logContextMock)

        // then

        let invokedComplete = await logContextMock.invokedComplete
        let invokedCompleteCount = await logContextMock.invokedCompleteCount

        XCTAssertTrue(invokedComplete)
        XCTAssertEqual(invokedCompleteCount, 1)
    }

    // MARK: - Private Methods

    private func makeSutWithoutLoggingProxy(method: NodeKit.Method) {
        sut = LoggerNode(
            next: nextNodeMock,
            method: method,
            route: urlProviderMock,
            loggingProxy: nil
        )
    }

    private func makeSutWithLoggingProxy(method: NodeKit.Method) {
        sut = LoggerNode(
            next: nextNodeMock,
            method: method,
            route: urlProviderMock,
            loggingProxy: loggingProxyMock
        )
    }
}
