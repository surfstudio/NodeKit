//
//  RequestSenderNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class RequestSenderNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<NodeDataResponse, Int>!
    private var urlSessionDataTaskActorMock: URLSessionDataTaskActorMock!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: RequestSenderNode<Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        urlSessionDataTaskActorMock = URLSessionDataTaskActorMock()
        logContextMock = LoggingContextMock()
        sut = RequestSenderNode(
            rawResponseProcessor: nextNodeMock,
            responseQueue: .main,
            dataTaskActor: urlSessionDataTaskActorMock,
            manager: NetworkMock().urlSession
        )
    }
    
    override func tearDown() {
        nextNodeMock = nil
        urlSessionDataTaskActorMock = nil
        logContextMock = nil
        sut = nil
        URLProtocolMock.flush()
    }
    
    // MARK: - Tests
    
    func testAsynProcess_thenLoadingStarted() async {
        // given
        
        let expectation = expectation(description: "result")

        URLProtocolMock.stubbedError = MockError.firstError
        nextNodeMock.stubbedAsyncProccessResult = .success(15)
        
        // when
        
        Task {
            _ = await sut.process(
                URLRequest(url: URL(string: "www.testprocess.com")!),
                logContext: logContextMock
            )
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        XCTAssertEqual(URLProtocolMock.invokedStartLoadingCount, 1)
    }
    
    func testAsyncProcess_whenResponseFailure_thenNextCalled() async throws {
        // given
        
        let expectation = expectation(description: "result")
        let url = URL(string: "www.testprocess.com")!
        let expectedRequest = URLRequest(url: url)
        
        URLProtocolMock.stubbedError = MockError.firstError
        nextNodeMock.stubbedAsyncProccessResult = .success(15)
        
        // when
        
        Task {
            _ = await sut.process(expectedRequest, logContext: logContextMock)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let error = try XCTUnwrap(input.result.error as? NSError)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertNil(input.urlResponse)
        XCTAssertEqual(input.urlRequest, expectedRequest)
        XCTAssertEqual(error.domain, "NodeKitTests.MockError")
    }
    
    func testAsyncProcess_whenFailure_thenDataTaskSaved() async throws {
        // given
        
        let expectation = expectation(description: "result")
        
        URLProtocolMock.stubbedError = MockError.firstError
        nextNodeMock.stubbedAsyncProccessResult = .success(15)
        
        // when
        
        Task {
            _ = await sut.process(
                URLRequest(url: URL(string: "www.testprocess.com")!),
                logContext: logContextMock
            )
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        let savedCount = await urlSessionDataTaskActorMock.invokedStoreCount
        XCTAssertEqual(savedCount, 1)
    }
    
    func testAsyncProcess_whenSuccess_thenDataTaskSaved() async throws {
        // given
        
        let expectation = expectation(description: "result")
        
        URLProtocolMock.stubbedRequestHandler = { _ in
            return (HTTPURLResponse(), Data())
        }
        nextNodeMock.stubbedAsyncProccessResult = .success(15)
        
        // when
        
        Task {
            _ = await sut.process(
                URLRequest(url: URL(string: "www.testprocess.com")!),
                logContext: logContextMock
            )
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        let parameter = await urlSessionDataTaskActorMock.invokedStoreParemeter
        let task = try XCTUnwrap(parameter)
        
        let savedCount = await urlSessionDataTaskActorMock.invokedStoreCount
        XCTAssertEqual(savedCount, 1)
        XCTAssertTrue(task is URLSessionDataTask)
    }
    
    func testAsyncProcess_whenResponseSuccess_thenNextCalled() async throws {
        // given
        
        let expectation = expectation(description: "result")
        let url = URL(string: "www.testprocess.com")!
        let expectedData = "TestData".data(using: .utf8)!
        let expectedRequest = URLRequest(url: url)
        let expectedResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        
        URLProtocolMock.stubbedRequestHandler = { _ in
            return (expectedResponse, expectedData)
        }
        
        nextNodeMock.stubbedAsyncProccessResult = .success(15)
        
        // when
        
        Task {
            _ = await sut.process(expectedRequest, logContext: logContextMock)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let response = try XCTUnwrap(input.urlResponse)
        let inputValue = try XCTUnwrap(input.result.value)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(response.statusCode, expectedResponse.statusCode)
        XCTAssertEqual(response.url, expectedResponse.url)
        XCTAssertEqual(response.headers.dictionary, expectedResponse.headers.dictionary)
        XCTAssertEqual(input.urlRequest, expectedRequest)
        XCTAssertEqual(inputValue, expectedData)
    }
    
    @MainActor
    func testAsyncProcess_nextReturnsSuccess_thenSuccessReceived() async throws {
        // given
        
        let expectation = expectation(description: "result")
        let expectedResult = 55
        let url = URL(string: "www.testprocess.com")!
        let expectedRequest = URLRequest(url: url)
        
        var result: NodeResult<Int>?
        
        URLProtocolMock.stubbedError = MockError.secondError
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        Task {
            result = await sut.process(expectedRequest, logContext: logContextMock)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        let value = try XCTUnwrap(result?.value)
        XCTAssertEqual(value, expectedResult)
    }
    
    @MainActor
    func testAsyncProcess_nextReturnsFailure_thenFailureReceived() async throws {
        // given
        
        let expectation = expectation(description: "result")
        
        var result: NodeResult<Int>?
        
        URLProtocolMock.stubbedRequestHandler = { _ in
            return (HTTPURLResponse(), Data())
        }
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        
        // when
        
        Task {
            result = await sut.process(
                URLRequest(url: URL(string: "www.testprocess.com")!),
                logContext: logContextMock
            )
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        let error = try XCTUnwrap(result?.error as? MockError)
        XCTAssertEqual(error, .secondError)
    }
    
    func testCancel_thenDataTaskCancelled() async {
        // when
        
        sut.cancel(logContext: logContextMock)
        
        // then
        
        try? await Task.sleep(nanoseconds: 1000000)
        
        let cancelCount = await urlSessionDataTaskActorMock.invokedCancelTaskCount
        XCTAssertEqual(cancelCount, 1)
    }
}
