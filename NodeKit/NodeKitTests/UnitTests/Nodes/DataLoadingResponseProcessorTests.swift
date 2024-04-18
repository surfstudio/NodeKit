//
//  DataLoadingResponseProcessorTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class DataLoadingResponseProcessorTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<URLDataResponse, Void>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: DataLoadingResponseProcessor!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = DataLoadingResponseProcessor(next: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProccess_whenNextIsNil_thenDataReceived() async throws {
        // given
        
        let expectedData = "TestData".data(using: .utf8)!
        let sut = DataLoadingResponseProcessor()
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: [:])!,
            data: expectedData
        )
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(value, expectedData)
    }
    
    func testAsyncProccess_whenNextIsNotNil_thenNextCalled() async throws {
        // given
        
        let url = URL(string: "www.test.com")!
        let headers = ["TestHeaderKey": "TestHeaderValue"]
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: headers)!,
            data: "TestData".data(using: .utf8)!
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(())
        
        // when
        
        _ = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input, response)
    }
    
    func testAsyncProccess_whenNextNodeReturnsSuccess_thenSuccessReceived() async throws {
        // given
        
        let expectedData = "TestExpectedData".data(using: .utf8)!
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: [:])!,
            data: expectedData
        )
        nextNodeMock.stubbedAsyncProccessResult = .success(())
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(value, expectedData)
    }
    
    func testAsyncProccess_whenNextNodeReturnsFailure_thenFailureReceived() async throws {
        // given
        
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: [:])!,
            data: Data()
        )
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .firstError)
    }
    
    func testAsyncProcess_withCancelTask_beforeStart_thenCancellationErrorReceived() async throws {
        // given
        
        let url = URL(string: "www.test.com")!
        let response = UrlDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: [:])!,
            data: Data(),
            metrics: nil,
            serializationDuration: 1
        )
        nextNodeMock.stubbedAsyncProccessResult = .success(())
        
        // when
        
        let task = Task {
            try? await Task.sleep(nanoseconds: 100 * 1000)
            return await sut.process(response, logContext: logContextMock)
        }
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
    
    func testAsyncProcess_withCancelTask_afterStart_thenCancellationErrorReceived() async throws {
        // given
        
        let url = URL(string: "www.test.com")!
        let response = UrlDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: [:])!,
            data: Data(),
            metrics: nil,
            serializationDuration: 1
        )
        nextNodeMock.stubbedAsyncProccessResult = .success(())
        nextNodeMock.stubbedAsyncProcessRunFunction = {
            try? await Task.sleep(nanoseconds: 3 * 1000 * 1000)
        }
        
        // when
        
        let task = Task {
            await sut.process(response, logContext: logContextMock)
        }
        
        try? await Task.sleep(nanoseconds: 100 * 1000)
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
}
