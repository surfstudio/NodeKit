//
//  DataLoadingResponseProcessorTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class DataLoadingResponseProcessorTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<UrlDataResponse, Void>!
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
        let response = UrlDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: [:])!,
            data: expectedData,
            metrics: nil,
            serializationDuration: 1
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
        let response = UrlDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: headers)!,
            data: "TestData".data(using: .utf8)!,
            metrics: nil,
            serializationDuration: 1
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
        let response = UrlDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: [:])!,
            data: expectedData,
            metrics: nil,
            serializationDuration: 1
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
        let response = UrlDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: [:])!,
            data: Data(),
            metrics: nil,
            serializationDuration: 1
        )
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .firstError)
    }
}
