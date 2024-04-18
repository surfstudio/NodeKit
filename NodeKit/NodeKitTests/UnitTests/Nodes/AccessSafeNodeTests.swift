//
//  AccessSafeNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 04.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class AccessSafeNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<TransportURLRequest, Json>!
    private var updateTokenChainMock: AsyncNodeMock<Void, Void>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: AccessSafeNode!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        updateTokenChainMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = AccessSafeNode(next: nextNodeMock, updateTokenChain: updateTokenChainMock)
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_thenNextCalled() async throws {
        // given
        
        let expectedResult = ["TestKey": "TestValue"]
        let url = URL(string: "www.testprocess.com")!
        let headers = ["TestHeaderKey": "TestHeaderValue"]
        let data = "Test".data(using: .utf8)!
        let request = TransportURLRequest(method: .connect, url: url, headers: headers, raw: data)
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        _ = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        let parameter = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(parameter, request)
    }
    
    func testAsyncProcess_whenNextReturnsSuccess_thenUpdateTokenDidNotCalled() async {
        // given
        
        let request = TransportURLRequest(
            method: .connect,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            raw: "Test".data(using: .utf8)!
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success([:])
        
        // when
        
        _ = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        XCTAssertFalse(updateTokenChainMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_whenNextReturnsSuccess_thenSuccessReceived() async throws {
        // given
        
        let expectedResult = ["TestKey": "TestValue"]
        let request = TransportURLRequest(
            method: .connect,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            raw: "Test".data(using: .utf8)!
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        let value = try XCTUnwrap(result.value as? [String: String])
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_whenNextReturnsCustomError_thenErrorReceived() async throws {
        // given
        
        let request = TransportURLRequest(
            method: .connect,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            raw: "Test".data(using: .utf8)!
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.thirdError)
        
        // when
        
        let result = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        XCTAssertEqual(error, .thirdError)
    }
    
    func testAsyncProcess_whenNextReturnsCustomError_thenTokenDidNotUpdate() async {
        // given
        
        let request = TransportURLRequest(
            method: .connect,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            raw: "Test".data(using: .utf8)!
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.thirdError)
        
        // when
        
        _ = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        XCTAssertFalse(updateTokenChainMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_whenForbidenErrorReceived_thenUpdateTokenStarted() async {
        // given
        
        let request = TransportURLRequest(
            method: .connect,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            raw: "Test".data(using: .utf8)!
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(ResponseHttpErrorProcessorNodeError.forbidden(Data()))
        updateTokenChainMock.stubbedAsyncProccessResult = .success(())
        
        // when
        
        _ = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        XCTAssertEqual(updateTokenChainMock.invokedAsyncProcessCount, 1)
    }
    
    func testAsyncProcess_whenUnauthorizedErrorReceived_thenUpdateTokenStarted() async {
        // given
        
        let request = TransportURLRequest(
            method: .connect,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            raw: "Test".data(using: .utf8)!
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(
            ResponseHttpErrorProcessorNodeError.unauthorized(Data())
        )
        updateTokenChainMock.stubbedAsyncProccessResult = .success(())
        
        // when
        
        _ = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        XCTAssertEqual(updateTokenChainMock.invokedAsyncProcessCount, 1)
    }
    
    func testAsyncProcess_whenTokenUpdateReturnsError_thenRequestDidNotRepeat() async {
        // given
        
        let request = TransportURLRequest(
            method: .connect,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            raw: "Test".data(using: .utf8)!
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(ResponseHttpErrorProcessorNodeError.forbidden(Data()))
        updateTokenChainMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        _ = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
    }
    
    func testAsyncProcess_whenTokenUpdateReturnsError_thenErrorReceived() async throws {
        // given
        
        let request = TransportURLRequest(
            method: .connect,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            raw: "Test".data(using: .utf8)!
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(ResponseHttpErrorProcessorNodeError.forbidden(Data()))
        updateTokenChainMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        XCTAssertEqual(error, .firstError)
    }
    
    func testAsyncProcess_whenTokenUpdateReturnsSuccess_thenRequestRepeated() async throws {
        // given
        
        let request = TransportURLRequest(
            method: .connect,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            raw: "Test".data(using: .utf8)!
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(ResponseHttpErrorProcessorNodeError.forbidden(Data()))
        updateTokenChainMock.stubbedAsyncProccessResult = .success(())
        
        // when
        
        _ = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        let firstInvokeData = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParametersList.first?.data)
        let secindInvokeData = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParametersList.first?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 2)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessParametersList.count, 2)
        XCTAssertEqual(firstInvokeData, request)
        XCTAssertEqual(secindInvokeData, request)
    }
    
    func testAsyncProcess_withCancelTask_beforeStart_thenCancellationErrorReceived() async throws {
        // given
        
        let request = TransportUrlRequest(
            method: .connect,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            raw: "Test".data(using: .utf8)!
        )
        
        updateTokenChainMock.stubbedAsyncProccessResult = .success(())
        nextNodeMock.stubbedAsyncProccessResult = .success(Json())
        
        // when
        
        let task = Task {
            try? await Task.sleep(nanoseconds: 100 * 1000)
            return await sut.process(request, logContext: LoggingContextMock())
        }
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
    
    func testAsyncProcess_withCancelTask_afterStart_thenCancellationErrorReceived() async throws {
        // given
        
        let request = TransportUrlRequest(
            method: .connect,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            raw: "Test".data(using: .utf8)!
        )
        
        updateTokenChainMock.stubbedAsyncProccessResult = .success(())
        nextNodeMock.stubbedAsyncProccessResult = .success(Json())
        nextNodeMock.stubbedAsyncProcessRunFunction = {
            try? await Task.sleep(nanoseconds: 3 * 1000 * 1000)
        }
        
        // when
        
        let task = Task {
            await sut.process(request, logContext: LoggingContextMock())
        }
        
        try? await Task.sleep(nanoseconds: 100 * 1000)
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
}
