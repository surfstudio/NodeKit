//
//  HeaderInjectorNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 04.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class HeaderInjectorNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<TransportUrlRequest, Json>!
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
    
    func testAsyncProcess_withoutHeaders_thenRequestWithOnlyPassedHeadersReceived() async throws {
        // given
        
        let expectedResult = ["ResultKey": "ResultValue"]
        let sut = HeaderInjectorNode(next: nextNodeMock, headers: [:])
        let expectedURL = URL(string: "www.testprocess.com")!
        let expectedHeaders = ["TestKey": "TestValue"]
        let expectedMethod: NodeKit.Method = .options
        let requestParameters = TransportUrlParameters(method: expectedMethod, url: expectedURL, headers: expectedHeaders)
        let expectedData = "TestData".data(using: .utf8)!
        let request = TransportUrlRequest(
            with: requestParameters, raw: expectedData)
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(request, logContext: logContextMock)
        
        // then
        
        let parameters = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let value = try XCTUnwrap(result.value as? [String: String])
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(parameters.url, expectedURL)
        XCTAssertEqual(parameters.method, expectedMethod)
        XCTAssertEqual(parameters.raw, expectedData)
        XCTAssertEqual(parameters.headers, expectedHeaders)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withHeaders_thenHeadersMergedWithPassedHeadersReceived() async throws {
        // given
        
        let expectedResult = ["ResultKey2": "ResultValue2"]
        let sut = HeaderInjectorNode(next: nextNodeMock, headers: [
            "TestFirstKey": "TestFirstValue",
            "TestSecondKey": "TestSecondValue"
        ])
        let expectedURL = URL(string: "www.testprocess.com")!
        let expectedMethod: NodeKit.Method = .options
        let expectedData = "TestData".data(using: .utf8)!
        let requestParameters = TransportUrlParameters(
            method: expectedMethod,
            url: expectedURL,
            headers: ["TestKey": "TestValue"]
        )
        let request = TransportUrlRequest(
            with: requestParameters, raw: expectedData)
        
        let expectedHeaders = [
            "TestKey": "TestValue",
            "TestFirstKey": "TestFirstValue",
            "TestSecondKey": "TestSecondValue"
        ]
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(request, logContext: logContextMock)
        
        // then
        
        let parameters = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let value = try XCTUnwrap(result.value as? [String: String])
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(parameters.url, expectedURL)
        XCTAssertEqual(parameters.method, expectedMethod)
        XCTAssertEqual(parameters.raw, expectedData)
        XCTAssertEqual(parameters.headers, expectedHeaders)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withHeadersAndSameKeys_thenHeadersMergedWithPassedHeadersReceived() async throws {
        // given
        
        let expectedResult = ["ResultKey3": "ResultValue3"]
        let sut = HeaderInjectorNode(next: nextNodeMock, headers: [
            "TestKey": "TestFirstValue",
            "TestSecondKey": "TestSecondValue"
        ])
        let expectedURL = URL(string: "www.testprocess.com")!
        let expectedMethod: NodeKit.Method = .options
        let expectedData = "TestData".data(using: .utf8)!
        let requestParameters = TransportUrlParameters(
            method: expectedMethod,
            url: expectedURL,
            headers: ["TestKey": "TestValue"]
        )
        let request = TransportUrlRequest(
            with: requestParameters, raw: expectedData)
        
        let expectedHeaders = [
            "TestKey": "TestValue",
            "TestSecondKey": "TestSecondValue"
        ]
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(request, logContext: logContextMock)
        
        // then
        
        let parameters = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let value = try XCTUnwrap(result.value as? [String: String])
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(parameters.url, expectedURL)
        XCTAssertEqual(parameters.method, expectedMethod)
        XCTAssertEqual(parameters.raw, expectedData)
        XCTAssertEqual(parameters.headers, expectedHeaders)
        XCTAssertEqual(value, expectedResult)
    }
}
