//
//  AsyncNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import Combine
import XCTest

final class AsyncNodeTests: XCTestCase {
    
    // MARK: - Sut
    
    private var logContextMock: LoggingContextMock!
    private var nodeMock: AsyncNodeMock<Int, Int>!
    private var cancellable: Set<AnyCancellable>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        logContextMock = LoggingContextMock()
        nodeMock = AsyncNodeMock()
        cancellable = Set()
    }
    
    override func tearDown() {
        super.tearDown()
        logContextMock = nil
        nodeMock = nil
        cancellable = nil
    }
    
    // MARK: - Tests
    
    func testCombineNode_thenCombineNodeCreated() async throws {
        // given
        
        let expectation = expectation(description: "result")
        let expectedInput = 4
        let expectedResult: NodeResult<Int> = .success(15)
        
        var result: NodeResult<Int>?
        
        nodeMock.stubbedAsyncProccessResult = expectedResult
        
        // when
        
        let sut = nodeMock.combineNode()
        sut.process(expectedInput, logContext: logContextMock)
            .eraseToAnyPublisher()
            .sink(receiveValue: { value in
                result = value
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        let unwrappedResult = try XCTUnwrap(result)
        
        XCTAssertEqual(nodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nodeMock.invokedAsyncProcessParameter, expectedInput)
        XCTAssertEqual(unwrappedResult.castToMockError(), expectedResult.castToMockError())
    }
    
    func testCombineNode_withMultipleSubsciptions_thenCombineNodeCreated() async throws {
        // given
        
        let expectation1 = expectation(description: "result1")
        let expectation2 = expectation(description: "result2")
        let expectedInput = 4
        let expectedResult: NodeResult<Int> = .success(13)
        
        var result1: NodeResult<Int>?
        var result2: NodeResult<Int>?
        
        nodeMock.stubbedAsyncProccessResult = expectedResult
        
        // when
        
        let sut = nodeMock.combineNode()
        
        sut.eraseToAnyPublisher()
            .sink(receiveValue: { value in
                result1 = value
                expectation1.fulfill()
            })
            .store(in: &cancellable)
        
        sut.eraseToAnyPublisher()
            .sink(receiveValue: { value in
                result2 = value
                expectation2.fulfill()
            })
            .store(in: &cancellable)
        
        sut.process(expectedInput, logContext: logContextMock)
        
        await fulfillment(of: [expectation1, expectation2], timeout: 0.1)
        
        // then
        
        let unwrappedResult1 = try XCTUnwrap(result1)
        let unwrappedResult2 = try XCTUnwrap(result2)
        
        XCTAssertEqual(nodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nodeMock.invokedAsyncProcessParameter, expectedInput)
        XCTAssertEqual(unwrappedResult1.castToMockError(), expectedResult.castToMockError())
        XCTAssertEqual(unwrappedResult2.castToMockError(), expectedResult.castToMockError())
    }
}
