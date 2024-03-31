//
//  AsyncStreamNodeAdapterTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class AsyncStreamNodeAdapterTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nodeMock: AsyncStreamNodeMock<Int, Int>!
    private var logContextMock: LoggingContextMock!
    private var outputMock: NodeAdapterOutputMock<Int>!
    
    // MARK: - Sut
    
    private var sut: AsyncStreamNodeAdapter<Int, Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nodeMock = AsyncStreamNodeMock()
        logContextMock = LoggingContextMock()
        outputMock = NodeAdapterOutputMock()
        sut = AsyncStreamNodeAdapter(node: nodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        outputMock = nil
        logContextMock = nil
        nodeMock = nil
    }
    
    // MARK: - Tests
    
    func testProcess_whenSuccess_thenSuccessResultSentToSubject() async {
        // given
        
        let expectation = expectation(description: "Method call")
        let expectedResults: [NodeResult<Int>] = [.success(1), .success(3), .success(5)]
        let expectedInput = 9
        
        nodeMock.stubbedAsyncStreamProccessResult = AsyncStream { continuation in
            expectedResults.forEach { value in
                continuation.yield(value)
            }
            continuation.finish()
        }
        nodeMock.stubbedAsyncStreamProcessRunFunction = {
            expectation.fulfill()
        }
        
        // when
        
        Task {
            await sut.process(data: expectedInput, logContext: logContextMock, output: outputMock)
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        let invokedOutputParameters = outputMock.invokedSendParameterList.compactMap { $0.castToMockError() }
        
        XCTAssertEqual(nodeMock.invokedAsyncStreamProcessCount, 1)
        XCTAssertEqual(nodeMock.invokedAsyncStreamProcessParameter, expectedInput)
        XCTAssertEqual(outputMock.invokedSendCount, expectedResults.count)
        XCTAssertEqual(outputMock.invokedSendParameterList.count, expectedResults.count)
        XCTAssertEqual(invokedOutputParameters, expectedResults.compactMap { $0.castToMockError() })
    }
    
    func testProcess_whenFailure_thenFailureResultSentToSubject() async {
        // given
        
        let expectation = expectation(description: "Method call")
        let expectedResults: [NodeResult<Int>] = [
            .failure(MockError.firstError),
            .failure(MockError.thirdError),
            .failure(MockError.secondError)
        ]
        let expectedInput = 8
        
        nodeMock.stubbedAsyncStreamProccessResult = AsyncStream { continuation in
            expectedResults.forEach { value in
                continuation.yield(value)
            }
            continuation.finish()
        }
        nodeMock.stubbedAsyncStreamProcessRunFunction = {
            expectation.fulfill()
        }
        
        // when
        
        Task {
            await sut.process(data: expectedInput, logContext: logContextMock, output: outputMock)
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        let invokedOutputParameters = outputMock.invokedSendParameterList.compactMap { $0.castToMockError() }
        
        XCTAssertEqual(nodeMock.invokedAsyncStreamProcessCount, 1)
        XCTAssertEqual(nodeMock.invokedAsyncStreamProcessParameter, expectedInput)
        XCTAssertEqual(outputMock.invokedSendCount, expectedResults.count)
        XCTAssertEqual(outputMock.invokedSendParameterList.count, expectedResults.count)
        XCTAssertEqual(invokedOutputParameters, expectedResults.compactMap { $0.castToMockError() })
    }
    
    func testProcess_whenSuccessWithFailure_thenSuccessWithFailureResultSentToSubject() async {
        // given
        
        let expectation = expectation(description: "Method call")
        let expectedResults: [Result<Int, MockError>] = [
            .success(5),
            .failure(.secondError),
            .success(2),
            .failure(.thirdError)
        ]
        let nodeStub: [NodeResult<Int>] = expectedResults.map { res in res.mapError { $0 } }
        let expectedInput = 7
        
        nodeMock.stubbedAsyncStreamProccessResult = AsyncStream { continuation in
            nodeStub.forEach { value in
                continuation.yield(value)
            }
            continuation.finish()
        }
        nodeMock.stubbedAsyncStreamProcessRunFunction = {
            expectation.fulfill()
        }
        
        // when
        
        Task {
            await sut.process(data: expectedInput, logContext: logContextMock, output: outputMock)
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        let invokedOutputParameters = outputMock.invokedSendParameterList.compactMap { $0.castToMockError() }
        
        XCTAssertEqual(nodeMock.invokedAsyncStreamProcessCount, 1)
        XCTAssertEqual(nodeMock.invokedAsyncStreamProcessParameter, expectedInput)
        XCTAssertEqual(outputMock.invokedSendCount, expectedResults.count)
        XCTAssertEqual(outputMock.invokedSendParameterList.count, expectedResults.count)
        XCTAssertEqual(invokedOutputParameters, expectedResults)
    }
}
