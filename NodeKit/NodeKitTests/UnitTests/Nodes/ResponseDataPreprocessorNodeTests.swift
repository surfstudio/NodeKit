//
//  ResponseDataPreprocessorNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 04.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class ResponseDataPreprocessorNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<URLDataResponse, Json>!
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
        let input = URLDataResponse(
            request: request,
            response: response,
            data: Data()
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
        let input = URLDataResponse(
            request: request,
            response: response,
            data: "null".data(using: .utf8)!
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
        let expectedInput = URLDataResponse(
            request: request,
            response: response,
            data: "TestString".data(using: .utf8)!
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
        let expectedInput = URLDataResponse(
            request: request,
            response: response,
            data: "TestString".data(using: .utf8)!
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
    
    func testAsyncProcess_withCancelTask_beforeStart_thenCancellationErrorReceived() async throws {
        // given
        
        let url = URL(string: "www.test.com")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: nil)!
        let input = URLDataResponse(
            request: request,
            response: response,
            data: Data()
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(Json())
        
        // when
        
        let task = Task {
            try? await Task.sleep(nanoseconds: 100 * 1000)
            return await sut.process(input, logContext: LoggingContextMock())
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
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 1, httpVersion: nil, headerFields: nil)!
        let input = URLDataResponse(
            request: request,
            response: response,
            data: Data()
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(Json())
        nextNodeMock.stubbedAsyncProcessRunFunction = {
            try? await Task.sleep(nanoseconds: 3 * 1000 * 1000)
        }
        
        // when
        
        let task = Task {
            await sut.process(input, logContext: LoggingContextMock())
        }
        
        try? await Task.sleep(nanoseconds: 100 * 1000)
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
}
