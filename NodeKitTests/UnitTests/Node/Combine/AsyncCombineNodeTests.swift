//
//  AsyncCombineNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 03.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
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
    
    func testnodeResultPublisher_withPublisherOnMainQueue_thenResultsReceivedOnMainQueue() async {
        let expectation = expectation(description: "result")
        
        var isMainThread = false
        
        nodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        sut.nodeResultPublisher(for: 1, on: DispatchQueue.main, logContext: logContextMock)
            .sink(receiveValue: { _ in
                isMainThread = Thread.isMainThread
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        XCTAssertTrue(isMainThread)
    }
    
    func testNodeResultPublisher_onCustomQueue_thenDataReceivedOnCustomQueue() async {
        // given
        
        let expectation = expectation(description: "result")
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
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        XCTAssertEqual(queueName, expectedQueueName)
    }
    
    func testNodeResultPublisher_whenResultIsSuccess_thenSuccessResultReceived() async throws {
        // given
        
        let expectation = expectation(description: "result")
        let expectedInput = 7
        let expectedResult: NodeResult<Int> = .success(8)
        
        var result: NodeResult<Int>?
        
        nodeMock.stubbedAsyncProccessResult = expectedResult
        
        // when
        
        sut.nodeResultPublisher(for: expectedInput, on: DispatchQueue.main, logContext: logContextMock)
            .sink(receiveValue: { value in
                result = value
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        let unwrappedResult = try XCTUnwrap(result)
        
        XCTAssertEqual(nodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nodeMock.invokedAsyncProcessParameters?.0, expectedInput)
        XCTAssertEqual(unwrappedResult.castToMockError(), expectedResult.castToMockError())
    }
    
    func testNodeResultPublisher_whithMultipleSubscriptions_thenResultsReceived() async throws {
        // given
        
        let expectation1 = expectation(description: "result1")
        let expectation2 = expectation(description: "result2")
        let expectedInput = 7
        let expectedResult: NodeResult<Int> = .success(8)
        
        var result1: NodeResult<Int>?
        var result2: NodeResult<Int>?
        
        nodeMock.stubbedAsyncProccessResult = expectedResult
        
        // when
        
        let publisher = sut.nodeResultPublisher(for: expectedInput, on: DispatchQueue.main, logContext: logContextMock)
        
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
        
        await fulfillment(of: [expectation1, expectation2], timeout: 0.1)
        
        // then
        
        let unwrappedResult1 = try XCTUnwrap(result1)
        let unwrappedResult2 = try XCTUnwrap(result2)
        
        XCTAssertEqual(nodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nodeMock.invokedAsyncProcessParameters?.0, expectedInput)
        XCTAssertEqual(unwrappedResult1.castToMockError(), expectedResult.castToMockError())
        XCTAssertEqual(unwrappedResult2.castToMockError(), expectedResult.castToMockError())
    }
    
    func testNodeResultPublisher_whenResultIsFailure_thenFailureResultReceived() async throws {
        // given
        
        let expectation = expectation(description: "result")
        let expectedInput = 9
        let expectedResult: NodeResult<Int> = .failure(MockError.firstError)
        
        var result: NodeResult<Int>?
        
        nodeMock.stubbedAsyncProccessResult = expectedResult
        
        // when
        
        sut.nodeResultPublisher(for: expectedInput, on: DispatchQueue.main, logContext: logContextMock)
            .sink(receiveValue: { value in
                result = value
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        let unwrappedResult = try XCTUnwrap(result)
        
        XCTAssertEqual(nodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nodeMock.invokedAsyncProcessParameters?.0, expectedInput)
        XCTAssertEqual(unwrappedResult.castToMockError(), expectedResult.castToMockError())
    }
}
