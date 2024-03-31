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
    
    // MARK: - Sut
    
    private var logContextMock: LoggingContextMock!
    private var nodeMock: AsyncStreamNodeMock<Int, Int>!
    private var cancellable: Set<AnyCancellable>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        logContextMock = LoggingContextMock()
        nodeMock = AsyncStreamNodeMock()
        cancellable = Set()
    }
    
    override func tearDown() {
        super.tearDown()
        logContextMock = nil
        nodeMock = nil
        cancellable = nil
    }
    
    // MARK: - Tests
    
    func testCombineNode_thenCombineNodeCreated() async {
        // given
        
        let expectation = expectation(description: "result")
        let expectedInput = 43
        
        let expectedResults: [Result<Int, Error>] = [
            .success(100),
            .failure(MockError.firstError),
            .failure(MockError.secondError),
            .success(99),
            .failure(MockError.thirdError)
        ]
        let castedResults = expectedResults.compactMap { $0.castToMockError() }
        
        var index: Int?
        var results: [NodeResult<Int>] = []
        
        nodeMock.stubbedAsyncStreamProccessResult = AsyncStream { continuation in
            expectedResults.forEach { continuation.yield($0) }
            continuation.finish()
        }
        
        // when
        
        let sut = nodeMock.combineNode()
        sut.process(data: expectedInput, logContext: logContextMock)
            .eraseToAnyPublisher()
            .sink(receiveValue: { value in
                results.append(value)
                if let valueIndex = index ?? value.findIndex(in: castedResults) {
                    index = valueIndex
                    if results.count == expectedResults.count - valueIndex {
                        expectation.fulfill()
                    }
                }
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 1)
        
        // then
        
        let allExpectedResults = Array(castedResults.dropFirst(index ?? 0))
        
        XCTAssertEqual(nodeMock.invokedAsyncStreamProcessCount, 1)
        XCTAssertEqual(nodeMock.invokedAsyncStreamProcessParameter, expectedInput)
        XCTAssertEqual(results.compactMap { $0.castToMockError() }, allExpectedResults)
    }
    
    func testCombineNode_withMultipleSubsciptions_thenCombineNodeCreated() async {
        // given
        
        let expectation1 = expectation(description: "result1")
        let expectation2 = expectation(description: "result2")
        let expectedInput = 42
        
        let expectedResults: [Result<Int, MockError>] = [
            .success(500),
            .failure(.secondError),
            .success(1),
            .failure(.secondError),
            .failure(.thirdError)
        ]
        let nodeResults: [NodeResult<Int>] = expectedResults.map { res in res.mapError { $0 } }
        
        var results1: [NodeResult<Int>] = []
        var results2: [NodeResult<Int>] = []
        
        
        nodeMock.stubbedAsyncStreamProccessResult = AsyncStream { continuation in
            nodeResults.forEach { continuation.yield($0) }
            continuation.finish()
        }
        
        // when
        
        let sut = nodeMock.combineNode()
        
        sut.eraseToAnyPublisher()
            .sink(receiveValue: { value in
                results1.append(value)
                if results1.count == expectedResults.count {
                    expectation1.fulfill()
                }
            })
            .store(in: &cancellable)
        
        sut.eraseToAnyPublisher()
            .sink(receiveValue: { value in
                results2.append(value)
                if results2.count == expectedResults.count {
                    expectation2.fulfill()
                }
            })
            .store(in: &cancellable)
        
        sut.process(data: expectedInput, logContext: logContextMock)
        
        await fulfillment(of: [expectation1, expectation2], timeout: 0.1)
        
        // then
        
        XCTAssertEqual(nodeMock.invokedAsyncStreamProcessCount, 1)
        XCTAssertEqual(nodeMock.invokedAsyncStreamProcessParameter, expectedInput)
        XCTAssertEqual(results1.compactMap { $0.castToMockError() }, expectedResults)
        XCTAssertEqual(results2.compactMap { $0.castToMockError() }, expectedResults)
    }
}
