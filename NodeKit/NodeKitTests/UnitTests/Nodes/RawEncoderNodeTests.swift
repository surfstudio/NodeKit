//
//  RawEncoderNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class RawEncoderNodeTests: XCTestCase {

    // MARK: - Dependecies
    
    private var rawEncodableMock: RawEncodableMock<Json>!
    private var nextNodeMock: AsyncNodeMock<Json, Int>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: RawEncoderNode<RawEncodableMock<Json>, Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        rawEncodableMock = RawEncodableMock()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = RawEncoderNode(next: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        rawEncodableMock = nil
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_whenSuccessRawEncoding_thenNextCalled() async throws {
        // given
        
        let expectedInput = ["name": "TestName", "value": "TestValue"]
        
        rawEncodableMock.stubbedToRawResult = .success(expectedInput)
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data as? [String: String])
        
        XCTAssertEqual(rawEncodableMock.invokedToRawCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input, expectedInput)
    }
    
    func testAsyncProcess_whenSuccessReturns_thenSuccessReceived() async throws {
        // given
    
        let expectedResult = 21
        
        rawEncodableMock.stubbedToRawResult = .success([:])
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_whenErrorReturns_thenErrorReceived() async throws {
        // given
    
        rawEncodableMock.stubbedToRawResult = .success([:])
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        XCTAssertEqual(error, .firstError)
    }
    
    func testAsyncProcess_withErrorEncoding_thenNextDidNotCall() async {
        // given
        
        rawEncodableMock.stubbedToRawResult = .failure(MockError.firstError)
        
        // when
        
        _ = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        XCTAssertEqual(rawEncodableMock.invokedToRawCount, 1)
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_whenErrorRawEncoding_thenErrorReceived() async throws {
        // given
        
        rawEncodableMock.stubbedToRawResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        XCTAssertEqual(error, .firstError)
    }
    
    func testAsyncProcess_withCancelTask_beforeStart_thenCancellationErrorReceived() async throws {
        // given
        
        rawEncodableMock.stubbedToRawResult = .success([:])
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        let task = Task {
            try? await Task.sleep(nanoseconds: 100 * 1000)
            return await sut.process(rawEncodableMock, logContext: LoggingContextMock())
        }
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
    
    func testAsyncProcess_withCancelTask_afterStart_thenCancellationErrorReceived() async throws {
        // given
        
        rawEncodableMock.stubbedToRawResult = .success([:])
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        nextNodeMock.stubbedAsyncProcessRunFunction = {
            try? await Task.sleep(nanoseconds: 3 * 1000 * 1000)
        }
        
        // when
        
        let task = Task {
            await sut.process(rawEncodableMock, logContext: LoggingContextMock())
        }
        
        try? await Task.sleep(nanoseconds: 100 * 1000)
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
}
