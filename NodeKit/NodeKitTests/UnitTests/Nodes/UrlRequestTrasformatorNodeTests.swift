//
//  UrlRequestTrasformatorNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class UrlRequestTrasformatorNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<RequestEncodingModel, Int>!
    private var logContextMock: LoggingContextMock!
    private var stubbedMethod: NodeKit.Method!
    private var urlRuteProviderMock: UrlRouteProviderMock!
    
    // MARK: - Sut
    
    private var sut: UrlRequestTrasformatorNode<Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        stubbedMethod = .trace
        urlRuteProviderMock = UrlRouteProviderMock()
        sut = UrlRequestTrasformatorNode(next: nextNodeMock, method: stubbedMethod)
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        stubbedMethod = nil
        urlRuteProviderMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_whenURLReturnsError_thenNextDidNotCalled() async {
        // given
        
        let model = EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding?>(
            metadata: [:],
            raw: [:],
            route: urlRuteProviderMock
        )
        
        urlRuteProviderMock.stubbedUrlResult = .failure(MockError.firstError)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_whenURLReturnsError_thenErrorReceived() async throws {
        // given
        
        let model = EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding?>(
            metadata: [:],
            raw: [:],
            route: urlRuteProviderMock
        )
        
        urlRuteProviderMock.stubbedUrlResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .firstError)
    }
    
    func testAsyncProcess_withCorrectUrl_thenNextCalled() async throws {
        // given
        
        let expectedUrl = URL(string: "www.test.com")!
        let expectedMetadata = ["TestMetadataKey": "TestMetadataValue"]
        let expectedRaw = ["TestJsonKey": "TestJsonValue"]
        let model = EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding?>(
            metadata: expectedMetadata,
            raw: expectedRaw,
            route: urlRuteProviderMock,
            encoding: .urlQuery
        )
        
        urlRuteProviderMock.stubbedUrlResult = .success(expectedUrl)
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let raw = try XCTUnwrap(input.raw as? [String: String])
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(raw, expectedRaw)
        XCTAssertEqual(input.encoding, .urlQuery)
        XCTAssertEqual(input.urlParameters.method, stubbedMethod)
        XCTAssertEqual(input.urlParameters.headers, expectedMetadata)
        XCTAssertEqual(input.urlParameters.url, expectedUrl)
    }
    
    func testAsyncProcess_withEncoding_thenEncodingPassed() async throws {
        // given
        
        let model = EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding?>(
            metadata: [:],
            raw: [:],
            route: urlRuteProviderMock,
            encoding: .json
        )
        
        urlRuteProviderMock.stubbedUrlResult = .success(URL(string: "www.test.com")!)
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.encoding, .json)
    }
    
    func testAsyncProcess_withoutEncoding_thenEncodingIsNil() async throws {
        // given
        
        let model = EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding?>(
            metadata: [:],
            raw: [:],
            route: urlRuteProviderMock,
            encoding: nil
        )
        
        urlRuteProviderMock.stubbedUrlResult = .success(URL(string: "www.test.com")!)
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertNil(input.encoding)
    }
    
    func testAsyncProcess_whenNextNodeReturnsSuccess_thenSuccessReceived() async throws {
        // given
        
        let expectedResult = 0079
        let model = EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding?>(
            metadata: [:],
            raw: [:],
            route: urlRuteProviderMock,
            encoding: nil
        )
        
        urlRuteProviderMock.stubbedUrlResult = .success(URL(string: "www.test.com")!)
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_whenNextNodeReturnsFailure_thenFailureReceived() async throws {
        // given
        
        let model = EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding?>(
            metadata: [:],
            raw: [:],
            route: urlRuteProviderMock,
            encoding: nil
        )
        
        urlRuteProviderMock.stubbedUrlResult = .success(URL(string: "www.test.com")!)
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .secondError)
    }
}
