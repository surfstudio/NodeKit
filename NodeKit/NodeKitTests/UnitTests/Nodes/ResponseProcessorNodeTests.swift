//
//  ResponseProcessorNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class ResponseProcessorNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<URLDataResponse, Int>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: ResponseProcessorNode<Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = ResponseProcessorNode(next: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_whenFailure_andWithoutURLResponse_thenNextDidNotCalled() async {
        // given
        
        let response = NodeDataResponse(
            urlResponse: nil,
            urlRequest: URLRequest(url: URL(string: "www.test.com")!),
            result: .failure(MockError.firstError)
        )
        
        // when
        
        _ = await sut.process(response, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_whenFailure_andWithoutURLResponse_thenErrorReceived() async throws {
        // given
        
        let response = NodeDataResponse(
            urlResponse: nil,
            urlRequest: URLRequest(url: URL(string: "www.test.com")!),
            result: .failure(MockError.firstError)
        )
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .firstError)
    }
    
    func testAsyncProcess_whenFailure_andWithoutURLRequest_thenNextDidNotCalled() async {
        // given
        
        let response = NodeDataResponse(
            urlResponse: HTTPURLResponse(),
            urlRequest: nil,
            result: .failure(MockError.firstError)
        )
        
        // when
        
        _ = await sut.process(response, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_whenFailure_andWithoutURLRequest_thenErrorReceived() async throws {
        // given
        
        let response = NodeDataResponse(
            urlResponse: HTTPURLResponse(),
            urlRequest: nil,
            result: .failure(MockError.secondError)
        )
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .secondError)
    }
    
    func testAsyncProcess_whenFailure_thenNextCalled() async throws {
        // given
        
        let urlResponse = HTTPURLResponse(
            url: URL(string: "www.test.com")!,
            statusCode: 200, 
            httpVersion: nil,
            headerFields: ["TestKey" :"TestValue"]
        )
        let request = URLRequest(url: URL(string: "www.test.com")!)
        let response = NodeDataResponse(
            urlResponse: urlResponse,
            urlRequest: request,
            result: .failure(MockError.thirdError)
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(input.response, urlResponse)
        XCTAssertEqual(input.request, request)
        XCTAssertTrue(input.data.isEmpty)
    }
    
    func testAsyncProcess_whenFailure_andNextReturnsSuccess_thenSuccessReceived() async throws {
        // given
        
        let expectedResult = 009
        let response = NodeDataResponse(
            urlResponse: HTTPURLResponse(),
            urlRequest: URLRequest(url: URL(string: "www.test.com")!),
            result: .failure(MockError.thirdError)
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_whenFailure_andNextReturnsFailure_thenFailureReceived() async throws {
        // given
        
        let response = NodeDataResponse(
            urlResponse: HTTPURLResponse(),
            urlRequest: URLRequest(url: URL(string: "www.test.com")!),
            result: .failure(MockError.thirdError)
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .secondError)
    }
    
    func testAsyncProcess_whenSuccess_andWithoutURLResponse_thenNextDidNotCalled() async {
        // given
        
        let response = NodeDataResponse(
            urlResponse: nil,
            urlRequest: URLRequest(url: URL(string: "www.test.com")!),
            result: .success(Data())
        )
        
        // when
        
        _ = await sut.process(response, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_whenSuccess_andWithoutURLResponse_thenErrorReceived() async throws {
        // given
        
        let response = NodeDataResponse(
            urlResponse: nil,
            urlRequest: URLRequest(url: URL(string: "www.test.com")!),
            result: .success(Data())
        )
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? ResponseProcessorNodeError)
        
        XCTAssertEqual(error, .rawResponseNotHaveMetaData)
    }
    
    func testAsyncProcess_whenSuccess_andWithoutURLRequest_thenNextDidNotCalled() async {
        // given
        
        let response = NodeDataResponse(
            urlResponse: HTTPURLResponse(),
            urlRequest: nil,
            result: .success(Data())
        )
        
        // when
        
        _ = await sut.process(response, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_whenSuccess_andWithoutURLRequest_thenErrorReceived() async throws {
        // given
        
        let response = NodeDataResponse(
            urlResponse: HTTPURLResponse(),
            urlRequest: nil,
            result: .success(Data())
        )
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? ResponseProcessorNodeError)
        
        XCTAssertEqual(error, .rawResponseNotHaveMetaData)
    }
    
    func testAsyncProcess_whenSuccess_thenNextCalled() async throws {
        // given
        
        let urlResponse = HTTPURLResponse(
            url: URL(string: "www.test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["TestKey" :"TestValue"]
        )
        let expectedData = "TestData".data(using: .utf8)!
        let request = URLRequest(url: URL(string: "www.test.com")!)
        let response = NodeDataResponse(
            urlResponse: urlResponse,
            urlRequest: request,
            result: .success(expectedData)
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(input.response, urlResponse)
        XCTAssertEqual(input.request, request)
        XCTAssertEqual(input.data, expectedData)
    }
    
    func testAsyncProcess_whenSuccess_andNextReturnsSuccess_thenSuccessReceived() async throws {
        // given
        
        let expectedResult = 009
        let response = NodeDataResponse(
            urlResponse: HTTPURLResponse(),
            urlRequest: URLRequest(url: URL(string: "www.test.com")!),
            result: .success(Data())
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_whenSuccess_andNextReturnsFailure_thenFailureReceived() async throws {
        // given
        
        let response = NodeDataResponse(
            urlResponse: HTTPURLResponse(),
            urlRequest: URLRequest(url: URL(string: "www.test.com")!),
            result: .success(Data())
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .secondError)
    }
    
    func testAsyncProcess_withCancelTask_beforeStart_thenCancellationErrorReceived() async throws {
        // given
        
        let response = NodeDataResponse(
            urlResponse: HTTPURLResponse(),
            urlRequest: URLRequest(url: URL(string: "www.test.com")!),
            result: .success(Data())
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
        
        let response = NodeDataResponse(
            urlResponse: HTTPURLResponse(),
            urlRequest: URLRequest(url: URL(string: "www.test.com")!),
            result: .success(Data())
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
