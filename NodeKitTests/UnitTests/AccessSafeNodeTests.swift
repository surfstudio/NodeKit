//
//  AccessSafeNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 04.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class AccessSafeNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<TransportUrlRequest, Json>!
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
    
    func testAsyncProcess_whenNextReturnsSuccess_thenUpdateTokenDidNotCalled() async throws {
        // given
        
        let expectedResult = ["TestKey": "TestValue"]
        let url = URL(string: "www.testprocess.com")!
        let headers = ["TestHeaderKey": "TestHeaderValue"]
        let data = "Test".data(using: .utf8)!
        let request = TransportUrlRequest(method: .connect, url: url, headers: headers, raw: data)
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        let value = try XCTUnwrap(result.value as? [String: String])
        let parameter = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(parameter, request)
        XCTAssertEqual(value, expectedResult)
        XCTAssertFalse(updateTokenChainMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_whenForbidenErrorReceived_andTokenUpdateReturnsError_thenRequestDidNotRepeat() async throws {
        // given
        
        let url = URL(string: "www.testprocess.com")!
        let headers = ["TestHeaderKey": "TestHeaderValue"]
        let data = "Test".data(using: .utf8)!
        let request = TransportUrlRequest(method: .connect, url: url, headers: headers, raw: data)
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(ResponseHttpErrorProcessorNodeError.forbidden(Data()))
        updateTokenChainMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        let parameter = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(parameter, request)
        XCTAssertEqual(error, .firstError)
        XCTAssertEqual(updateTokenChainMock.invokedAsyncProcessCount, 1)
    }
    
    func testAsyncProcess_whenForbidenErrorReceived_andTokenUpdateReturnsSuccess_thenRequestRepeated() async throws {
        // given
        
        let expectedResult = ["TestKey": "TestValue"]
        let url = URL(string: "www.testprocess.com")!
        let headers = ["TestHeaderKey": "TestHeaderValue"]
        let data = "Test".data(using: .utf8)!
        let request = TransportUrlRequest(method: .connect, url: url, headers: headers, raw: data)
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(ResponseHttpErrorProcessorNodeError.forbidden(Data()))
        updateTokenChainMock.stubbedAsyncProccessResult = .success(())
        updateTokenChainMock.stubbedAsyncProcessRunFunction = { [weak self] in
            self?.nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        }
        
        // when
        
        let result = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        let value = try XCTUnwrap(result.value as? [String: String])
        let firstParameter = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParametersList.first?.0)
        let secondParameter = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParametersList.last?.0)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 2)
        XCTAssertEqual(firstParameter, request)
        XCTAssertEqual(secondParameter, request)
        XCTAssertEqual(value, expectedResult)
        XCTAssertEqual(updateTokenChainMock.invokedAsyncProcessCount, 1)
    }
    
    func testAsyncProcess_whenUnauthorizedErrorReceived_andTokenUpdateReturnsError_thenRequestDidNotRepeat() async throws {
        // given
        
        let url = URL(string: "www.testprocess.com")!
        let headers = ["TestHeaderKey": "TestHeaderValue"]
        let data = "Test".data(using: .utf8)!
        let request = TransportUrlRequest(method: .connect, url: url, headers: headers, raw: data)
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(ResponseHttpErrorProcessorNodeError.unauthorized(Data()))
        updateTokenChainMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        
        // when
        
        let result = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        let parameter = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(parameter, request)
        XCTAssertEqual(error, .secondError)
        XCTAssertEqual(updateTokenChainMock.invokedAsyncProcessCount, 1)
    }
    
    func testAsyncProcess_whenUnauthorizedErrorReceived_andTokenUpdateReturnsSuccess_thenRequestRepeated() async throws {
        // given
        
        let expectedResult = ["TestKey": "TestValue"]
        let url = URL(string: "www.testprocess.com")!
        let headers = ["TestHeaderKey": "TestHeaderValue"]
        let data = "Test".data(using: .utf8)!
        let request = TransportUrlRequest(method: .connect, url: url, headers: headers, raw: data)
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(ResponseHttpErrorProcessorNodeError.unauthorized(Data()))
        updateTokenChainMock.stubbedAsyncProccessResult = .success(())
        updateTokenChainMock.stubbedAsyncProcessRunFunction = { [weak self] in
            self?.nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        }
        
        // when
        
        let result = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        let value = try XCTUnwrap(result.value as? [String: String])
        let firstParameter = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParametersList.first?.0)
        let secondParameter = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParametersList.last?.0)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 2)
        XCTAssertEqual(firstParameter, request)
        XCTAssertEqual(secondParameter, request)
        XCTAssertEqual(value, expectedResult)
        XCTAssertEqual(updateTokenChainMock.invokedAsyncProcessCount, 1)
    }
    
    func testAsyncProcess_whenCustomErrorReceived_thenTokenDidNotUpdateAndCustomErrorReceived() async throws {
        // given
        
        let url = URL(string: "www.testprocess.com")!
        let headers = ["TestHeaderKey": "TestHeaderValue"]
        let data = "Test".data(using: .utf8)!
        let request = TransportUrlRequest(method: .connect, url: url, headers: headers, raw: data)
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.thirdError)
        
        // when
        
        let result = await sut.process(request, logContext: LoggingContextMock())
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        let parameter = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(parameter, request)
        XCTAssertEqual(error, .thirdError)
        XCTAssertFalse(updateTokenChainMock.invokedAsyncProcess)
    }
}
