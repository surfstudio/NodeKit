//
//  AsyncStreamNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
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
        
        XCTAssertEqual(sut.invokedAsyncStreamProcessCount, 1)
        XCTAssertEqual(sut.invokedAsyncStreamProcessParameter?.0, expectedInput)
        XCTAssertFalse(sut.invokedAsyncStreamProcessParameter?.1 === logContextMock)
        XCTAssertEqual(
            results.compactMap { $0.castToMockError() },
            expectedResults.compactMap { $0.castToMockError() }
        )
    }
    
    func testCombineStreamNode_thenAsyncStreamCombineNodeBasedOnSutReceived() async {
        // given
        
        let sut = AsyncStreamNodeMock<Int, Int>()
        let expectation = expectation(description: "result")
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
        
        let node = sut.combineStreamNode()
        
        node.nodeResultPublisher(on: DispatchQueue.main)
            .sink(receiveValue: { value in
                results.append(value)
                if results.count == expectedResults.count {
                    expectation.fulfill()
                }
            })
            .store(in: &cancellable)
        
        node.process(expectedInput, logContext: logContextMock)
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        XCTAssertEqual(sut.invokedAsyncStreamProcessCount, 1)
        XCTAssertEqual(sut.invokedAsyncStreamProcessParameter?.0, expectedInput)
        XCTAssertTrue(sut.invokedAsyncStreamProcessParameter?.1 === logContextMock)
        XCTAssertTrue(node is AsyncStreamCombineNode<Int, Int>)
        XCTAssertEqual(
            results.compactMap { $0.castToMockError() },
            expectedResults.compactMap { $0.castToMockError() }
        )
    }
}
