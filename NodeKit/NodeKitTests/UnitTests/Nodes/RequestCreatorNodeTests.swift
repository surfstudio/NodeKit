//
//  RequestCreatorNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 04.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class RequestCreatorNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<URLRequest, Int>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_withoutProviders_thenRequestWithOnlyPassedHeadersReceived() async throws {
        // given
        
        let expectedResult = 66
        let sut = RequestCreatorNode<Int>(next: nextNodeMock)
        let expectedURL = URL(string: "www.testprocess.com")!
        let expectedHeaders = ["TestKey": "TestValue"]
        let expectedMethod: NodeKit.Method = .options
        let requestParameters = TransportURLParameters(method: expectedMethod, url: expectedURL, headers: expectedHeaders)
        let expectedData = "TestData".data(using: .utf8)!
        let request = TransportURLRequest(
            with: requestParameters, raw: expectedData)
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(request, logContext: logContextMock)
        
        // then
        
        let parameters = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(parameters.url, expectedURL)
        XCTAssertEqual(parameters.httpMethod, expectedMethod.rawValue)
        XCTAssertEqual(parameters.httpBody, expectedData)
        XCTAssertEqual(parameters.headers.dictionary, expectedHeaders)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withProviders_thenProvidersHeadersMergedWithPassedHeadersReceived() async throws {
        // given
        
        let expectedResult = 66
        let firstProvider = MetadataProviderMock()
        let secondProvider = MetadataProviderMock()
        let providers = [
            firstProvider,
            secondProvider
        ]
        let sut = RequestCreatorNode<Int>(next: nextNodeMock, providers: providers)
        let expectedURL = URL(string: "www.testprocess.com")!
        let expectedMethod: NodeKit.Method = .options
        let expectedData = "TestData".data(using: .utf8)!
        let requestParameters = TransportURLParameters(
            method: expectedMethod,
            url: expectedURL,
            headers: ["TestKey": "TestValue"]
        )
        let request = TransportURLRequest(
            with: requestParameters, raw: expectedData)
        
        let expectedHeaders = [
            "TestKey": "TestValue",
            "TestFirstProviderKey": "TestFirstProviderValue",
            "TestSecondProviderKey": "TestSecondProviderValue"
        ]
        
        firstProvider.stubbedMetadataResult = ["TestFirstProviderKey": "TestFirstProviderValue"]
        secondProvider.stubbedMetadataResult = ["TestSecondProviderKey": "TestSecondProviderValue"]
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(request, logContext: logContextMock)
        
        // then
        
        let parameters = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(parameters.url, expectedURL)
        XCTAssertEqual(parameters.httpMethod, expectedMethod.rawValue)
        XCTAssertEqual(parameters.httpBody, expectedData)
        XCTAssertEqual(parameters.headers.dictionary, expectedHeaders)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withProvidersAndSameKeys_thenProvidersHeadersMergedWithPassedHeadersReceived() async throws {
        // given
        
        let expectedResult = 66
        let firstProvider = MetadataProviderMock()
        let secondProvider = MetadataProviderMock()
        let providers = [
            firstProvider,
            secondProvider
        ]
        let sut = RequestCreatorNode<Int>(next: nextNodeMock, providers: providers)
        let expectedURL = URL(string: "www.testprocess.com")!
        let expectedMethod: NodeKit.Method = .options
        let expectedData = "TestData".data(using: .utf8)!
        let requestParameters = TransportURLParameters(
            method: expectedMethod,
            url: expectedURL,
            headers: ["TestKey": "TestValue"]
        )
        let request = TransportURLRequest(
            with: requestParameters, raw: expectedData)
        
        let expectedHeaders = [
            "TestKey": "TestSecondProviderValue",
            "TestFirstProviderKey": "TestFirstProviderValue"
        ]
        
        firstProvider.stubbedMetadataResult = ["TestFirstProviderKey": "TestFirstProviderValue"]
        secondProvider.stubbedMetadataResult = ["TestKey": "TestSecondProviderValue"]
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(request, logContext: logContextMock)
        
        // then
        
        let parameters = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(parameters.url, expectedURL)
        XCTAssertEqual(parameters.httpMethod, expectedMethod.rawValue)
        XCTAssertEqual(parameters.httpBody, expectedData)
        XCTAssertEqual(parameters.headers.dictionary, expectedHeaders)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withCancelTask_beforeStart_thenCancellationErrorReceived() async throws {
        // given
        
        let sut = RequestCreatorNode<Int>(next: nextNodeMock, providers: [])
        let requestParameters = TransportURLParameters(
            method: .options,
            url: URL(string: "www.testprocess.com")!,
            headers: [:]
        )
        let request = TransportURLRequest(with: requestParameters, raw: Data())
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
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
        
        let sut = RequestCreatorNode<Int>(next: nextNodeMock, providers: [])
        let requestParameters = TransportURLParameters(
            method: .options,
            url: URL(string: "www.testprocess.com")!,
            headers: [:]
        )
        let request = TransportURLRequest(with: requestParameters, raw: Data())
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
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
