//
//  URLCacheWriterNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class URLCacheWriterNodeTest: XCTestCase {
    
    // MARK: - Dependencies
    
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: URLCacheWriterNode!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        logContextMock = LoggingContextMock()
        sut = URLCacheWriterNode()
    }
    
    override func tearDown() {
        super.tearDown()
        logContextMock = nil
        sut = nil
        URLCache.shared.removeAllCachedResponses()
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_thenCacheWriteSuccess() async throws {
        // given
        
        let url = URL(string: "http://example.test")!
        let request = URLRequest(url: url)
        let responseKey = "name"
        let responseValue = "test"
        let response = [responseKey: responseValue]
        let responseData = try! JSONSerialization.data(
            withJSONObject: response,
            options: .sortedKeys
        )
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: nil)!
        let urlDataResponse = URLDataResponse(
            request: request,
            response: urlResponse,
            data: responseData
        )
        let input = URLProcessedResponse(dataResponse: urlDataResponse, json: [responseKey: responseValue])
        
        // when
        
        let result = await sut.process(input, logContext: logContextMock)
        
        // then
        
        let cachedResponse = try XCTUnwrap(URLCache.shared.cachedResponse(for: request))
        
        XCTAssertEqual(cachedResponse.data, responseData)
        XCTAssertEqual(cachedResponse.response, urlResponse)
        XCTAssertEqual(cachedResponse.storagePolicy, .allowed)
        XCTAssertNotNil(result.value)
    }
    
    func testAsyncProcess_withCancelTask_thenCancellationErrorReceived() async throws {
        // given
        
        let url = URL(string: "http://example.test")!
        let request = URLRequest(url: url)
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: nil)!
        let urlDataResponse = UrlDataResponse(
            request: request,
            response: urlResponse,
            data: Data(),
            metrics: nil,
            serializationDuration: 1
        )
        let input = UrlProcessedResponse(dataResponse: urlDataResponse, json: [:])
        
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
}
