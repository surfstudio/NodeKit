//
//  ResponseDataPreprocessorNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 04.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class ResponseDataPreprocessorNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<UrlDataResponse, Json>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: ResponseDataPreprocessorNode!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = ResponseDataPreprocessorNode(next: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_whenResponseHas204Code_thenEmptyJsonReceived() async throws {
        // given
        
        let url = URL(string: "www.test.com")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 204, httpVersion: nil, headerFields: nil)!
        let input = UrlDataResponse(
            request: request,
            response: response,
            data: Data(),
            metrics: nil,
            serializationDuration: 0
        )
        
        // when
        
        let result = await sut.process(input, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
        XCTAssertTrue(value.isEmpty)
    }
    
    func testAsyncProcess_whenJsonIsNull_thenEmptyJsonReceived() async throws {
        // given
        
        let url = URL(string: "www.test.com")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: nil)!
        let input = UrlDataResponse(
            request: request,
            response: response,
            data: "null".data(using: .utf8)!,
            metrics: nil,
            serializationDuration: 0
        )
        
        // when
        
        let result = await sut.process(input, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
        XCTAssertTrue(value.isEmpty)
    }
    
    func testAsyncProcess_whenCorrectJson_thenNextCalled() async throws {
        // given
        
        let url = URL(string: "www.test.com")!
        let request = URLRequest(url: url)
        let expectedResult = ["TestKey": "TestValue"]
        let response = HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: nil)!
        let expectedInput = UrlDataResponse(
            request: request,
            response: response,
            data: "TestString".data(using: .utf8)!,
            metrics: nil,
            serializationDuration: 0
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(expectedInput, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value as? [String: String])
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessParameters?.data, expectedInput)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_whenNextNodeReturnsError_thenErrorReceived() async throws {
        // given
        
        let url = URL(string: "www.test.com")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: nil)!
        let expectedInput = UrlDataResponse(
            request: request,
            response: response,
            data: "TestString".data(using: .utf8)!,
            metrics: nil,
            serializationDuration: 0
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.thirdError)
        
        // when
        
        let result = await sut.process(expectedInput, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessParameters?.data, expectedInput)
        XCTAssertEqual(error, .thirdError)
    }
}
