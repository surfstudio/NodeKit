//
//  AsyncStreamNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Combine
import XCTest

final class AsyncStreamNodeTests: XCTestCase {
    
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
        cancellable.forEach {
            $0.cancel()
        }
        cancellable = nil
    }
    
    // MARK: - Tests
    
    func testAsyncStreamProcess_whenDataIsVoid_thenMainMethodCalled() async throws {
        // given
        
        let sut = AsyncStreamNodeMock<Void, Int>()
        
        let expectedResults: [Result<Int, Error>] = [
            .success(100),
            .failure(MockError.firstError),
            .failure(MockError.secondError),
            .success(99),
            .failure(MockError.thirdError)
        ]
        
        var results: [NodeResult<Int>] = []
        
        sut.stubbedAsyncStreamProccessResult = {
            AsyncStream { continuation in
                expectedResults.forEach { continuation.yield($0) }
                continuation.finish()
            }
        }
        
        // when
        
        for await result in sut.process() {
            results.append(result)
        }
        
        // then
        
        XCTAssertEqual(sut.invokedAsyncStreamProcessCount, 1)
        XCTAssertEqual(
            results.compactMap { $0.castToMockError() },
            expectedResults.compactMap { $0.castToMockError() }
        )
    }
    
    func testAsyncProcess_withData_thenNewLogContextCreated() async throws {
        // given
        
        let sut = AsyncStreamNodeMock<Int, Int>()
        let expectedInput = 32
        
        let expectedResults: [Result<Int, Error>] = [
            .success(100),
            .failure(MockError.firstError),
            .failure(MockError.secondError),
            .success(99),
            .failure(MockError.thirdError)
        ]
        
        var results: [NodeResult<Int>] = []
        
        sut.stubbedAsyncStreamProccessResult = {
            AsyncStream { continuation in
                expectedResults.forEach { continuation.yield($0) }
                continuation.finish()
            }
        }
        
        // when
        
        for await result in sut.process(expectedInput) {
            results.append(result)
        }
        
        // then
        
        let input = try XCTUnwrap(sut.invokedAsyncStreamProcessParameter)
        
        XCTAssertEqual(sut.invokedAsyncStreamProcessCount, 1)
        XCTAssertEqual(input.data, expectedInput)
        XCTAssertFalse(input.logContext === logContextMock)
        XCTAssertEqual(
            results.compactMap { $0.castToMockError() },
            expectedResults.compactMap { $0.castToMockError() }
        )
    }
    
    @MainActor
    func testProcess_withPublisherOnMainQueue_thenResultsReceivedOnMainQueue() async {
        // given
        
        let sut = AsyncStreamNodeMock<Int, Int>()
        let expectation = expectation(description: #function)
        
        var isMainThread = false
        
        sut.stubbedAsyncStreamProccessResult = {
            AsyncStream { continuation in
                continuation.yield(.success(100))
                continuation.finish()
            }
        }
        
        // when
        
        sut.nodeResultPublisher(for: 12, on: DispatchQueue.main, logContext: logContextMock)
            .sink(receiveValue: { value in
                isMainThread = Thread.isMainThread
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 3)
        
        // then
        
        XCTAssertTrue(isMainThread)
    }
    
    func testProcess_withPublisherOnCustomQueue_thenResultsReceivedOnCustomQueue() async {
        // given
        
        let sut = AsyncStreamNodeMock<Int, Int>()
        let expectation = expectation(description: #function)
        let expectedLabel = "Test Process Queue"
        let queue = DispatchQueue(label: expectedLabel)
        
        var isMainThread = false
        var queueLabel: String?
        
        sut.stubbedAsyncStreamProccessResult = {
            AsyncStream { continuation in
                continuation.yield(.success(100))
                continuation.finish()
            }
        }
        
        // when
        
        sut.nodeResultPublisher(for: 12, on: queue, logContext: logContextMock)
            .sink(receiveValue: { value in
                isMainThread = Thread.isMainThread
                queueLabel = DispatchQueue.currentLabel
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 3)
        
        // then
        
        XCTAssertFalse(isMainThread)
        XCTAssertEqual(queueLabel, expectedLabel)
    }
    
    @MainActor
    func testProcess_thenResultsReceived() async throws {
        // given
        
        let sut = AsyncStreamNodeMock<Int, Int>()
        let expectation = expectation(description: #function)
        let expectedInput = 43
        
        let expectedResults: [Result<Int, Error>] = [
            .success(100),
            .failure(MockError.firstError),
            .failure(MockError.secondError),
            .success(99),
            .failure(MockError.thirdError)
        ]
        
        var results: [NodeResult<Int>] = []
        
        sut.stubbedAsyncStreamProccessResult = {
            AsyncStream { continuation in
                expectedResults.forEach { continuation.yield($0) }
                continuation.finish()
            }
        }
        
        // when
        
        sut.nodeResultPublisher(for: expectedInput, on: DispatchQueue.main, logContext: logContextMock)
            .sink(receiveValue: { value in
                results.append(value)
                if results.count == expectedResults.count {
                    expectation.fulfill()
                }
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 3)
        
        // then
        
        let input = try XCTUnwrap(sut.invokedAsyncStreamProcessParameter)
        
        XCTAssertEqual(sut.invokedAsyncStreamProcessCount, 1)
        XCTAssertEqual(input.data, expectedInput)
        XCTAssertTrue(input.logContext === logContextMock)
        XCTAssertEqual(
            results.compactMap { $0.castToMockError() },
            expectedResults.compactMap { $0.castToMockError() }
        )
    }
    
    func testEraseToAnyNode_thenAnyNodeBasedOnSelfCreated() async throws {
        // given
        
        let sut = AsyncStreamNodeMock<Void, Int>()
        
        let expectedResults: [Result<Int, Error>] = [
            .success(100),
            .failure(MockError.firstError),
            .failure(MockError.secondError),
            .success(99),
            .failure(MockError.thirdError)
        ]
        
        var results: [NodeResult<Int>] = []
        
        sut.stubbedAsyncStreamProccessResult = {
            AsyncStream { continuation in
                expectedResults.forEach { continuation.yield($0) }
                continuation.finish()
            }
        }
        
        // when
        
        for await result in sut.eraseToAnyNode().process() {
            results.append(result)
        }
        
        // then
        
        XCTAssertEqual(sut.invokedAsyncStreamProcessCount, 1)
        XCTAssertEqual(
            results.compactMap { $0.castToMockError() },
            expectedResults.compactMap { $0.castToMockError() }
        )
    }
}
