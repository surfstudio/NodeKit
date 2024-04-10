//
//  AsyncCombineNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 03.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Combine
import XCTest

final class AsyncCombineNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nodeMock: AsyncNodeMock<Int, Int>!
    private var logContextMock: LoggingContextMock!
    private var cancellable: Set<AnyCancellable>!
    
    // MARK: - Sut
    
    private var sut: AsyncCombineNode<Int, Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = AsyncCombineNode(node: nodeMock)
        cancellable = Set()
    }
    
    override func tearDown() {
        super.tearDown()
        nodeMock = nil
        logContextMock = nil
        sut = nil
        cancellable = Set()
    }
    
    // MARK: - Tests
    
    @MainActor
    func testnodeResultPublisher_withPublisherOnMainQueue_thenResultsReceivedOnMainQueue() async {
        let expectation = expectation(description: #function)
        
        var isMainThread = false
        
        nodeMock.stubbedAsyncProccessResult = .success(1)
        
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
        
        let expectation = expectation(description: #function)
        let expectedQueueName = "Test Process Queue"
        let queue = DispatchQueue(label: expectedQueueName)
        
        var queueName: String?
        
        nodeMock.stubbedAsyncProccessResult = .success(1)
        
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
    func testNodeResultPublisher_thenNextNodeCalled() async throws {
        // given
        
        let expectation = expectation(description: #function)
        let expectedInput = 7
        let expectedResult: NodeResult<Int> = .success(8)
        
        nodeMock.stubbedAsyncProccessResult = expectedResult
        
        // when
        
        sut.nodeResultPublisher(for: expectedInput, on: DispatchQueue.main, logContext: logContextMock)
            .sink(receiveValue: { value in
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 3)
        
        // then
        
        let input = try XCTUnwrap(nodeMock.invokedAsyncProcessParameters)
        
        XCTAssertEqual(nodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.data, expectedInput)
    }
    
    @MainActor
    func testNodeResultPublisher_whenResultIsSuccess_thenSuccessResultReceived() async throws {
        // given
        
        let expectation = expectation(description: #function)
        let expectedResult = 8
        
        var result: NodeResult<Int>?
        
        nodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
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
    
    @MainActor
    func testNodeResultPublisher_whithMultipleSubscriptions_thenResultsReceived() async throws {
        // given
        
        let expectation1 = expectation(description: #function + "1")
        let expectation2 = expectation(description: #function + "2")
        let expectedResult = 8
        
        var result1: NodeResult<Int>?
        var result2: NodeResult<Int>?
        
        nodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let publisher = sut.nodeResultPublisher(for: 2, on: DispatchQueue.main, logContext: logContextMock)
        
        publisher
            .sink(receiveValue: { value in
                result1 = value
                expectation1.fulfill()
            })
            .store(in: &cancellable)
        
        publisher
            .sink(receiveValue: { value in
                result2 = value
                expectation2.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation1, expectation2], timeout: 3)
        
        // then
        
        let value1 = try XCTUnwrap(result1?.value)
        let value2 = try XCTUnwrap(result2?.value)
        
        XCTAssertEqual(value1, expectedResult)
        XCTAssertEqual(value2, expectedResult)
    }
    
    @MainActor
    func testNodeResultPublisher_whenResultIsFailure_thenFailureResultReceived() async throws {
        // given
        
        let expectation = expectation(description: #function)
        
        var result: NodeResult<Int>?
        
        nodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        sut.nodeResultPublisher(for: 5, on: DispatchQueue.main, logContext: logContextMock)
            .sink(receiveValue: { value in
                result = value
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 3)
        
        // then
        
        let error = try XCTUnwrap(result?.error as? MockError)
        
        XCTAssertEqual(error, .firstError)
    }
}
