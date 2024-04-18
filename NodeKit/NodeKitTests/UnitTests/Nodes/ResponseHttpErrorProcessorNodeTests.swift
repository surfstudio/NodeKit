//
//  ResponseHttpErrorProcessorNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class ResponseHttpErrorProcessorNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<URLDataResponse, Int>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: ResponseHttpErrorProcessorNode<Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = ResponseHttpErrorProcessorNode(next: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Test
    
    func testAsyncProcess_with400CodeResponse_thenNextDidNotCalled() async {
        // given
        
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)!,
            data: Data()
        )
        
        // when
        
        _ = await sut.process(response, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_with401CodeResponse_thenNextDidNotCalled() async {
        // given
        
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!,
            data: Data()
        )
        
        // when
        
        _ = await sut.process(response, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_with403CodeResponse_thenNextDidNotCalled() async {
        // given
        
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 403, httpVersion: nil, headerFields: nil)!,
            data: Data()
        )
        
        // when
        
        _ = await sut.process(response, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_with404CodeResponse_thenNextDidNotCalled() async {
        // given
        
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!,
            data: Data()
        )
        
        // when
        
        _ = await sut.process(response, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_with500CodeResponse_thenNextDidNotCalled() async {
        // given
        
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!,
            data: Data()
        )
        
        // when
        
        _ = await sut.process(response, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_with400CodeResponse_thenBadRequestErrorReceived() async throws {
        // given
        
        let expectedData = "TestData".data(using: .utf8)!
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)!,
            data: expectedData
        )
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? ResponseHttpErrorProcessorNodeError)
        
        if case let .badRequest(data) = error {
            XCTAssertEqual(data, expectedData)
        } else {
            XCTFail("Не верный результат работы метода")
        }
    }
    
    func testAsyncProcess_with401CodeResponse_thenUnauthorizedErrorReceived() async throws {
        // given
        
        let expectedData = "TestData".data(using: .utf8)!
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!,
            data: expectedData
        )
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? ResponseHttpErrorProcessorNodeError)
        
        if case let .unauthorized(data) = error {
            XCTAssertEqual(data, expectedData)
        } else {
            XCTFail("Не верный результат работы метода")
        }
    }
    
    func testAsyncProcess_with403CodeResponse_thenForbiddenErrorReceived() async throws {
        // given
        
        let expectedData = "TestData".data(using: .utf8)!
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 403, httpVersion: nil, headerFields: nil)!,
            data: expectedData
        )
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? ResponseHttpErrorProcessorNodeError)
        
        if case let .forbidden(data) = error {
            XCTAssertEqual(data, expectedData)
        } else {
            XCTFail("Не верный результат работы метода")
        }
    }
    
    func testAsyncProcess_with404CodeResponse_thenNotFoundErrorReceived() async throws {
        // given
        
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!,
            data: Data()
        )
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? ResponseHttpErrorProcessorNodeError)
        
        if case .notFound = error {
            return
        } else {
            XCTFail("Не верный результат работы метода")
        }
    }
    
    func testAsyncProcess_with500CodeResponse_thenInternalServerErrorReceived() async throws {
        // given
        
        let expectedData = "TestData".data(using: .utf8)!
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!,
            data: expectedData
        )
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? ResponseHttpErrorProcessorNodeError)
        
        if case let .internalServerError(data) = error {
            XCTAssertEqual(data, expectedData)
        } else {
            XCTFail("Не верный результат работы метода")
        }
    }
    
    func testAsyncProcess_withCustomCode_thenNextCalled() async throws {
        // given
        
        let expectedData = "TestData".data(using: .utf8)!
        let url = URL(string: "www.test.com")!
        let expectedResponse = HTTPURLResponse(url: url, statusCode: 402, httpVersion: nil, headerFields: nil)!
        let expectedRequest = URLRequest(url: url)
        let response = URLDataResponse(
            request: expectedRequest,
            response: expectedResponse,
            data: expectedData
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        let _ = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.response, expectedResponse)
        XCTAssertEqual(input.request, expectedRequest)
        XCTAssertEqual(input.data, expectedData)
    }
    
    func testAsyncProcess_whenNextReturnsSuccess_thenSuccessReceived() async throws {
        // given
        
        let expectedResult = 901
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 402, httpVersion: nil, headerFields: nil)!,
            data: Data()
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_whenNextReturnsFailure_thenFailureReceived() async throws {
        // given
        
        let url = URL(string: "www.test.com")!
        let response = URLDataResponse(
            request: URLRequest(url: url),
            response: HTTPURLResponse(url: url, statusCode: 402, httpVersion: nil, headerFields: nil)!,
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
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!,
            data: Data(),
            metrics: nil,
            serializationDuration: 1
        )
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
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
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!,
            data: Data(),
            metrics: nil,
            serializationDuration: 1
        )
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
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
