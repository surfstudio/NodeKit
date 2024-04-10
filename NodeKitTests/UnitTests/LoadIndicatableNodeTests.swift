//
//  LoadIndicatableNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class LoadIndicatableNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<Int, Int>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: LoadIndicatableNode<Int, Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = LoadIndicatableNode(next: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_thenNextCalled() async throws {
        // given
        
        let expectedInput = 006
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(expectedInput, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input, expectedInput)
    }
    
    func testAsyncProcess_whenNextReturnsSuccess_thenSuccessReceived() async throws {
        // given
        
        let expectedResult = 0089
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(1, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_whenNextReturnsFailure_thenFailureReceived() async throws {
        // given
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(1, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .firstError)
    }
    
    @MainActor
    func testAsyncProcess_thenIndicatorIncremented() async {
        // given
        
        var count = 0
        let expectation = expectation(description: #function)
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        nextNodeMock.stubbedAsyncProcessRunFunction = {
            count += 1
            if count == 2 {
                expectation.fulfill()
            }
            try? await Task.sleep(nanoseconds: 5000000000)
        }
        
        // when
        
        Task {
            _ = await sut.process(1, logContext: logContextMock)
        }
        
        Task {
            _ = await sut.process(1, logContext: logContextMock)
        }
        
        await fulfillment(of: [expectation], timeout: 3)
        
        // then
        
        XCTAssertEqual(LoadIndicatableNodeStatic.requestConter, 2)
    }
    
    func testAsyncProcess_thenIndicatorDecremented() async {
        // given
        
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(1, logContext: logContextMock)
        _ = await sut.process(1, logContext: logContextMock)
        
        try? await Task.sleep(nanoseconds: 100000000)
        
        // then
        
        XCTAssertEqual(LoadIndicatableNodeStatic.requestConter, 0)
    }
}
