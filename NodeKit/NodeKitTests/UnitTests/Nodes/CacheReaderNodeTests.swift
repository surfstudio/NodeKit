//
//  CacheReaderNodeTests.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 01/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Foundation
import XCTest

final class CacheReaderNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: URLCacheReaderNode!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        logContextMock = LoggingContextMock()
        sut = URLCacheReaderNode()
    }
    
    override func tearDown() {
        super.tearDown()
        logContextMock = nil
        sut = nil
        URLCache.shared.removeAllCachedResponses()
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_whenHasData_thenReadSuccess() async throws {
        // given

        let url = URL(string: "http://example.test")!
        let request = URLRequest(url: url)
        let model = URLNetworkRequest(urlRequest: request)
        let responseKey = "name"
        let responseValue = "test"
        let response = [responseKey: responseValue]
        let responseData = try! JSONSerialization.data(
            withJSONObject: response,
            options: .sortedKeys
        )
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: nil)!
        let cachedRequest = CachedURLResponse(response: urlResponse, data: responseData)
        
        URLCache.shared.storeCachedResponse(cachedRequest, for: request)

        // when

        let result = await sut.process(model, logContext: logContextMock)

        // then

        let json = try XCTUnwrap(result.value as? [String: String])

        XCTAssertEqual(json, response)
    }
    
    func testAsyncProcess_whenJsonArray_thenReadSuccess() async throws {
        // given

        let url = URL(string: "http://example.test")!
        let request = URLRequest(url: url)
        let model = URLNetworkRequest(urlRequest: request)
        let responseKey = "name"
        let responseValue = "test"
        let response = [[responseKey: responseValue], [responseKey: responseValue]]
        let responseData = try! JSONSerialization.data(
            withJSONObject: response,
            options: .sortedKeys
        )
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: nil)!
        let cachedRequest = CachedURLResponse(response: urlResponse, data: responseData)
        
        URLCache.shared.storeCachedResponse(cachedRequest, for: request)

        // when

        let result = await sut.process(model, logContext: logContextMock)

        // then

        let json = try XCTUnwrap(result.value as? [String: [[String: String]]])
        let value = try XCTUnwrap(json[MappingUtils.arrayJsonKey])

        XCTAssertEqual(value, response)
    }

    func testAsyncProcess_withWrongRequest_thenDataDidNotRead() async throws {
        // given

        let url = URL(string: "http://example.test/usr?id=123")!
        let request = URLRequest(url: url)
        let responseData = try! JSONSerialization.data(
            withJSONObject: ["name": "test"],
            options: .sortedKeys
        )
        let urlResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "1.1",
            headerFields: nil
        )!
        let cachedRequest = CachedURLResponse(response: urlResponse, data: responseData)
        let notOwnRequest = URLRequest(url: URL(string: "http://example.test/usr?ud=321")!)
        let model = URLNetworkRequest(urlRequest: notOwnRequest)
        
        URLCache.shared.storeCachedResponse(cachedRequest, for: request)

        // when
        
        let result = await sut.process(model, logContext: logContextMock)

        // ghen
        
        let error = try XCTUnwrap(result.error as? BaseURLCacheReaderError)

        XCTAssertEqual(error, .cantLoadDataFromCache)
    }

    func testAsyncProcess_whenDataNotJson_thenSerializationErrorReceived() async throws {
        // given

        let url = URL(string: "http://example.test")!
        let request = URLRequest(url: url)
        let model = URLNetworkRequest(urlRequest: request)
        let responseData = "{1:1}".data(using: .utf8)!
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: nil)!
        let cachedRequest = CachedURLResponse(response: urlResponse, data: responseData)

        URLCache.shared.storeCachedResponse(cachedRequest, for: request)

        // when

        let result = await sut.process(model, logContext: logContextMock)

        // ghen
        
        let error = try XCTUnwrap(result.error as? BaseURLCacheReaderError)

        XCTAssertEqual(error, .cantSerializeJson)
    }

    func testAsyncProcess_withBadJson_thenCantCastToJsonErrorReceived() async throws {
        // given

        let url = URL(string: "http://example.test")!
        let request = URLRequest(url: url)
        let model = URLNetworkRequest(urlRequest: request)
        let responseData = "12345".data(using: .utf8)!
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: nil)!
        let cachedRequest = CachedURLResponse(response: urlResponse, data: responseData)

        URLCache.shared.storeCachedResponse(cachedRequest, for: request)

        // when

        let result = await sut.process(model, logContext: logContextMock)

        // ghen
        
        let error = try XCTUnwrap(result.error as? BaseURLCacheReaderError)

        XCTAssertEqual(error, .cantCastToJson)
    }
    
    func testAsyncProcess_withCancelTask_thenCancellationErrorReceived() async throws {
        // given
        
        let url = URL(string: "http://example.test")!
        let request = URLRequest(url: url)
        let model = URLNetworkRequest(urlRequest: request)
        
        // when
        
        let task = Task {
            try? await Task.sleep(nanoseconds: 100 * 1000)
            return await sut.process(model, logContext: LoggingContextMock())
        }
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
}
