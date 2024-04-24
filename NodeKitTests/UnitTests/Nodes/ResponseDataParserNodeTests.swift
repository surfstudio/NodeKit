//
//  ResponseDataParserNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 04.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class ResponseDataParserNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<UrlProcessedResponse, Void>!
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
    
    func testAsyncProcess_whenDataCountIsZero_thenEmptyJsonReceived() async throws {
        // given
        
        let sut = ResponseDataParserNode(next: nextNodeMock)
        let url = URL(string: "www.test.com")!
        let expectedRequest = URLRequest(url: url)
        let expectedData = Data()
        let expectedResponse = HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: .zero, textEncodingName: nil)
        let expectedSerializationDuration: TimeInterval = 42
        let response = UrlDataResponse(
            request: expectedRequest,
            response: expectedResponse,
            data: expectedData,
            metrics: nil,
            serializationDuration: expectedSerializationDuration
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(())
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let parameter = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(parameter.request, expectedRequest)
        XCTAssertEqual(parameter.response, expectedResponse)
        XCTAssertEqual(parameter.data, expectedData)
        XCTAssertEqual(parameter.metrics, nil)
        XCTAssertEqual(parameter.serializationDuration, expectedSerializationDuration)
        XCTAssertTrue(parameter.json.isEmpty)
        XCTAssertTrue(value.isEmpty)
    }
    
    func testAsyncProcess_whenDataSerializationError_thenCantCastDesirializedDataToJsonErrorReceived() async throws {
        // given
        
        let sut = ResponseDataParserNode(next: nextNodeMock)
        let url = URL(string: "www.test.com")!
        let expectedRequest = URLRequest(url: url)
        let expectedData = "{1:1}".data(using: .utf8)!
        let expectedResponse = HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: .zero, textEncodingName: nil)
        let expectedSerializationDuration: TimeInterval = 42
        let response = UrlDataResponse(
            request: expectedRequest,
            response: expectedResponse,
            data: expectedData,
            metrics: nil,
            serializationDuration: expectedSerializationDuration
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(())
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? ResponseDataParserNodeError)
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
        
        if case .cantCastDesirializedDataToJson = error {
            return
        } else {
            XCTFail("Не верный результат работы метода")
        }
    }
    
    func testAsyncProcess_whenJsonSerializationError_thenCantDeserializeJsonErrorReceived() async throws {
        // given
        
        let sut = ResponseDataParserNode(next: nextNodeMock)
        let url = URL(string: "www.test.com")!
        let expectedRequest = URLRequest(url: url)
        let expectedData = "15".data(using: .utf8)!
        let expectedResponse = HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: .zero, textEncodingName: nil)
        let expectedSerializationDuration: TimeInterval = 42
        let response = UrlDataResponse(
            request: expectedRequest,
            response: expectedResponse,
            data: expectedData,
            metrics: nil,
            serializationDuration: expectedSerializationDuration
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(())
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? ResponseDataParserNodeError)
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
        
        if case .cantDeserializeJson = error {
            return
        } else {
            XCTFail("Не верный результат работы метода")
        }
    }
    
    func testAsyncProcess_withJson_thenJsonReceived() async throws {
        // given
        
        let sut = ResponseDataParserNode(next: nextNodeMock)
        let url = URL(string: "www.test.com")!
        let expectedRequest = URLRequest(url: url)
        let expectedResult = ["TestKey1": "TestValue1", "TestKey2": "TestValue2"]
        let jsonData = try JSONSerialization.data(withJSONObject: expectedResult)
        let expectedResponse = HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: .zero, textEncodingName: nil)
        let expectedSerializationDuration: TimeInterval = 42
        let response = UrlDataResponse(
            request: expectedRequest,
            response: expectedResponse,
            data: jsonData,
            metrics: nil,
            serializationDuration: expectedSerializationDuration
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(())
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let parameter = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let inputJson = try XCTUnwrap(parameter.json as? [String: String])
        let value = try XCTUnwrap(result.value as? [String: String])
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(parameter.request, expectedRequest)
        XCTAssertEqual(parameter.response, expectedResponse)
        XCTAssertEqual(parameter.data, jsonData)
        XCTAssertEqual(parameter.metrics, nil)
        XCTAssertEqual(parameter.serializationDuration, expectedSerializationDuration)
        XCTAssertEqual(inputJson, expectedResult)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withJson_andWithoutNextNode_thenJsonReceived() async throws {
        // given
        
        let sut = ResponseDataParserNode()
        let url = URL(string: "www.test.com")!
        let expectedRequest = URLRequest(url: url)
        let expectedResult = ["TestKey1": "TestValue1", "TestKey2": "TestValue2"]
        let jsonData = try JSONSerialization.data(withJSONObject: expectedResult)
        let expectedResponse = HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: .zero, textEncodingName: nil)
        let expectedSerializationDuration: TimeInterval = 42
        let response = UrlDataResponse(
            request: expectedRequest,
            response: expectedResponse,
            data: jsonData,
            metrics: nil,
            serializationDuration: expectedSerializationDuration
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(())
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value as? [String: String])
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withArrayOfJson_thenArrayOfJsonReceived() async throws {
        // given
        
        let sut = ResponseDataParserNode(next: nextNodeMock)
        let url = URL(string: "www.test.com")!
        let expectedRequest = URLRequest(url: url)
        let expectedResult = [["TestKey1": "TestValue1"], ["TestKey2": "TestValue2"]]
        let jsonData = try JSONSerialization.data(withJSONObject: expectedResult)
        let expectedResponse = HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: .zero, textEncodingName: nil)
        let expectedSerializationDuration: TimeInterval = 42
        let response = UrlDataResponse(
            request: expectedRequest,
            response: expectedResponse,
            data: jsonData,
            metrics: nil,
            serializationDuration: expectedSerializationDuration
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(())
        
        // when
        
        let result = await sut.process(response, logContext: logContextMock)
        
        // then
        
        let parameter = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let inputJson = try XCTUnwrap(parameter.json[MappingUtils.arrayJsonKey] as? [[String: String]])
        let value = try XCTUnwrap(result.value?[MappingUtils.arrayJsonKey] as? [[String: String]])
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(parameter.request, expectedRequest)
        XCTAssertEqual(parameter.response, expectedResponse)
        XCTAssertEqual(parameter.data, jsonData)
        XCTAssertEqual(parameter.metrics, nil)
        XCTAssertEqual(parameter.serializationDuration, expectedSerializationDuration)
        XCTAssertEqual(inputJson, expectedResult)
        XCTAssertEqual(value, expectedResult)
    }
}
