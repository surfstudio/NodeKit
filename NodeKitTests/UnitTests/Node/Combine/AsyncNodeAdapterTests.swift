//
//  AsyncNodeAdapterTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class AsyncNodeAdapterTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nodeMock: AsyncNodeMock<Int, Int>!
    private var logContextMock: LoggingContextMock!
    private var outputMock: NodeAdapterOutputMock<Int>!
    
    // MARK: - Sut
    
    private var sut: AsyncNodeAdapter<Int, Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        outputMock = NodeAdapterOutputMock()
        sut = AsyncNodeAdapter(node: nodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        outputMock = nil
        logContextMock = nil
        nodeMock = nil
    }
    
    // MARK: - Tests
    
    func testProcess_whenSuccess_thenSuccessResultSentToSubject() async throws {
        // given
        
        let expectation = expectation(description: "Method call")
        let expectedResult: NodeResult<Int> = .success(6)
        let expectedInput = 3
        
        nodeMock.stubbedAsyncProccessResult = expectedResult
        nodeMock.stubbedAsyncProcessRunFunction = {
            expectation.fulfill()
        }
        
        // when
        
        Task {
            await sut.process(data: expectedInput, logContext: logContextMock, output: outputMock)
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        let unwrappedResult = try XCTUnwrap(outputMock.invokedSendParameter)
        
        XCTAssertEqual(nodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nodeMock.invokedAsyncProcessParameter, expectedInput)
        XCTAssertEqual(outputMock.invokedSendCount, 1)
        XCTAssertEqual(unwrappedResult.castToMockError(), expectedResult.castToMockError())
    }
    
    func testProcess_whenFailure_thenFailureResultSentToSubject() async throws {
        // given
        
        let expectation = expectation(description: "Method call")
        let expectedResult: NodeResult<Int> = .failure(MockError.firstError)
        let expectedInput = 10
        
        nodeMock.stubbedAsyncProccessResult = expectedResult
        nodeMock.stubbedAsyncProcessRunFunction = {
            expectation.fulfill()
        }
        
        // when
        
        Task {
            await sut.process(data: expectedInput, logContext: logContextMock, output: outputMock)
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        let unwrappedResult = try XCTUnwrap(outputMock.invokedSendParameter)
        
        XCTAssertEqual(nodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nodeMock.invokedAsyncProcessParameter, expectedInput)
        XCTAssertEqual(outputMock.invokedSendCount, 1)
        XCTAssertEqual(unwrappedResult.castToMockError(), expectedResult.castToMockError())
    }
}
