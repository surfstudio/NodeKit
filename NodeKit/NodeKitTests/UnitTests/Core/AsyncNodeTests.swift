//
//  AsyncNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Combine
import XCTest

final class AsyncNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var logContextMock: LoggingContextMock!
    private var cancellable: Set<AnyCancellable>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        logContextMock = LoggingContextMock()
        cancellable = Set()
    }
    
    override func tearDown() {
        super.tearDown()
        logContextMock = nil
        cancellable = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_whenDataIsVoid_thenMainMethodCalled() async throws {
        // given
        
        let sut = AsyncNodeMock<Void, Int>()
        let expectedResult = 2
        
        sut.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process()
        
        // then
        
        let input = try XCTUnwrap(sut.invokedAsyncProcessParameters)
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(sut.invokedAsyncProcessCount, 1)
        XCTAssertFalse(input.logContext === logContextMock)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withData_thenNewLogContextCreated() async throws {
        // given
        
        let sut = AsyncNodeMock<Int, Int>()
        let expectedInput = 1
        let expectedResult = 3
        
        sut.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(expectedInput)
        
        // then
        
        let input = try XCTUnwrap(sut.invokedAsyncProcessParameters)
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(sut.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.data, expectedInput)
        XCTAssertFalse(input.logContext === logContextMock)
        XCTAssertEqual(value, expectedResult)
    }
    
    @MainActor
    func testnodeResultPublisher_withPublisherOnMainQueue_thenResultsReceivedOnMainQueue() async {
        let sut = AsyncNodeMock<Int, Int>()
        let expectation = expectation(description: #function)
        
        var isMainThread = false
        
        sut.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        sut.nodeResultPublisher(for: 1, on: DispatchQueue.main, logContext: logContextMock)
            .sink(receiveValue: { _ in
                isMainThread = Thread.isMainThread
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 3)
        
        // then
        
        XCTAssertTrue(isMainThread)
    }
    
    func testNodeResultPublisher_onCustomQueue_thenDataReceivedOnCustomQueue() async {
        // given
        
        let sut = AsyncNodeMock<Int, Int>()
        let expectation = expectation(description: #function)
        let expectedQueueName = "Test Process Queue"
        let queue = DispatchQueue(label: expectedQueueName)
        
        var queueName: String?
        
        sut.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        sut.nodeResultPublisher(for: 1, on: queue, logContext: logContextMock)
            .sink(receiveValue: { _ in
                queueName = DispatchQueue.currentLabel
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 3)
        
        // then
        
        XCTAssertEqual(queueName, expectedQueueName)
    }
    
    @MainActor
    func testNodeResultPublisher_thenProcessNodeCalled() async throws {
        // given
        
        let sut = AsyncNodeMock<Int, Int>()
        let expectation = expectation(description: #function)
        let expectedInput = 7
        let expectedResult: NodeResult<Int> = .success(8)
        
        sut.stubbedAsyncProccessResult = expectedResult
        
        // when
        
        sut.nodeResultPublisher(for: expectedInput, on: DispatchQueue.main, logContext: logContextMock)
            .sink(receiveValue: { value in
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 3)
        
        // then
        
        let input = try XCTUnwrap(sut.invokedAsyncProcessParameters)
        
        XCTAssertEqual(sut.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.data, expectedInput)
    }
    
    @MainActor
    func testNodeResultPublisher_whenResultIsSuccess_thenSuccessResultReceived() async throws {
        // given
        
        let sut = AsyncNodeMock<Int, Int>()
        let expectation = expectation(description: #function)
        let expectedResult = 8
        
        var result: NodeResult<Int>?
        
        sut.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        sut.nodeResultPublisher(for: 1, on: DispatchQueue.main, logContext: logContextMock)
            .sink(receiveValue: { value in
                result = value
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 3)
        
        // then
        
        let value = try XCTUnwrap(result?.value)
        
        XCTAssertEqual(value, expectedResult)
    }
    
    func testEraseToAnyNode_thenAnyNodeBasedOnSelfCreated() async throws {
        // given
        
        let sut = AsyncNodeMock<Void, Int>()
        let expectedResult = 2
        
        sut.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.eraseToAnyNode().process()
        
        // then
        
        let input = try XCTUnwrap(sut.invokedAsyncProcessParameters)
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(sut.invokedAsyncProcessCount, 1)
        XCTAssertFalse(input.logContext === logContextMock)
        XCTAssertEqual(value, expectedResult)
    }
}
