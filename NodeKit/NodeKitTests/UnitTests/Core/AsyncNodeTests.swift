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
    
    func testCombineNode_thenAsyncCombineNodeBasedOnSutReceived() async throws {
        // given
        
        let sut = AsyncNodeMock<Int, Int>()
        let expectation = expectation(description: #function)
        let expectedInput = 15
        let expectedResult = 21
        let logContext = LoggingContextMock()
        
        sut.stubbedAsyncProccessResult = .success(expectedResult)
        
        var result: NodeResult<Int>?
        
        // when
        
        let node = sut.combineNode()
        
        node.nodeResultPublisher(for: expectedInput, on: DispatchQueue.main, logContext: logContext)
            .sink(receiveValue: { value in
                result = value
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 3)
        
        // then
        
        let input = try XCTUnwrap(sut.invokedAsyncProcessParameters)
        let value = try XCTUnwrap(result?.value)
        
        XCTAssertTrue(node is AsyncCombineNode<Int, Int>)
        XCTAssertEqual(sut.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.data, expectedInput)
        XCTAssertTrue(input.logContext === logContext)
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
