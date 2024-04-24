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
        let expectedResult: NodeResult<Int> = .success(2)
        
        sut.stubbedAsyncProccessResult = expectedResult
        
        // when
        
        let result = await sut.process()
        
        // then
        
        let unwrappedResult = try XCTUnwrap(result)
        
        XCTAssertEqual(sut.invokedAsyncProcessCount, 1)
        XCTAssertFalse(sut.invokedAsyncProcessParameter?.1 === logContextMock)
        XCTAssertEqual(unwrappedResult.castToMockError(), expectedResult.castToMockError())
    }
    
    func testAsyncProcess_withData_thenNewLogContextCreated() async throws {
        // given
        
        let sut = AsyncNodeMock<Int, Int>()
        let expectedInput = 1
        let expectedResult: NodeResult<Int> = .success(2)
        
        sut.stubbedAsyncProccessResult = expectedResult
        
        // when
        
        let result = await sut.process(expectedInput)
        
        // then
        
        let unwrappedResult = try XCTUnwrap(result)
        
        XCTAssertEqual(sut.invokedAsyncProcessCount, 1)
        XCTAssertEqual(sut.invokedAsyncProcessParameter?.0, expectedInput)
        XCTAssertFalse(sut.invokedAsyncProcessParameter?.1 === logContextMock)
        XCTAssertEqual(unwrappedResult.castToMockError(), expectedResult.castToMockError())
    }
    
    func testCombineNode_thenAsyncCombineNodeBasedOnSutReceived() async {
        // given
        
        let sut = AsyncNodeMock<Int, Int>()
        let expectation = expectation(description: "result")
        let expectedInput = 15
        let expectedResult: NodeResult<Int> = .success(21)
        let logContext = LoggingContextMock()
        
        sut.stubbedAsyncProccessResult = expectedResult
        
        var result: NodeResult<Int>?
        
        // when
        
        let node = sut.combineNode()
        
        node.nodeResultPublisher(for: expectedInput, on: DispatchQueue.main, logContext: logContext)
            .sink(receiveValue: { value in
                result = value
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        XCTAssertTrue(node is AsyncCombineNode<Int, Int>)
        XCTAssertEqual(sut.invokedAsyncProcessCount, 1)
        XCTAssertEqual(sut.invokedAsyncProcessParameter?.0, expectedInput)
        XCTAssertTrue(sut.invokedAsyncProcessParameter?.1 === logContext)
        XCTAssertEqual(result?.castToMockError(), expectedResult.castToMockError())
    }
}
