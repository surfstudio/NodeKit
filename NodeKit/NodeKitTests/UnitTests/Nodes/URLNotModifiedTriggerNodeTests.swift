//
//  URLNotModifiedTriggerNodeTests.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Foundation
import XCTest

final class URLNotModifiedTriggerNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var transportNodeMock: AsyncNodeMock<URLDataResponse, Json>!
    private var cacheSaverMock: AsyncNodeMock<URLNetworkRequest, Json>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: URLNotModifiedTriggerNode!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        transportNodeMock = AsyncNodeMock()
        cacheSaverMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = URLNotModifiedTriggerNode(next: transportNodeMock, cacheReader: cacheSaverMock)
    }
    
    override func tearDown() {
        super.tearDown()
        transportNodeMock = nil
        cacheSaverMock = nil
        logContextMock = nil
        sut = nil
    }

    // MARK: - Tests
    
    func testAsyncProcess_whenDataIsNotModified_thenNextCalled() async throws {
        // given
        
        let url = URL(string: "http://UrlETagUrlCacheTriggerNode.test/testNextCalledIfDataIsNotNotModified")!
        let response = Utils.getMockURLDataResponse(url: url)
        let expectedNextResult = ["Test": "Value"]
        
        transportNodeMock.stubbedAsyncProccessResult = .success(expectedNextResult)

        // when

        let result = await sut.process(response, logContext: logContextMock)

        // then

        let unwrappedResult = try XCTUnwrap(try result.get() as? [String: String])
        
        XCTAssertEqual(transportNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(transportNodeMock.invokedAsyncProcessParameters?.data, response)
        XCTAssertFalse(cacheSaverMock.invokedAsyncProcess)
        XCTAssertEqual(unwrappedResult, expectedNextResult)
    }
    
    func testAsyncProcess_whenStatus304_thenCacheNodeCalled() async throws {
        // given

        let url = URL(string: "http://UrlETagUrlCacheTriggerNode.test/testNextCAlledIfDataIsNotNotModified")!
        let response = Utils.getMockURLDataResponse(url: url, statusCode: 304)
        let expectedCacheResult = ["Test": "Value"]
        
        cacheSaverMock.stubbedAsyncProccessResult = .success(expectedCacheResult)

        // when

        let result = await sut.process(response, logContext: logContextMock)

        // then

        let unwrappedResult = try XCTUnwrap(try result.get() as? [String: String])

        XCTAssertFalse(transportNodeMock.invokedAsyncProcess)
        XCTAssertEqual(cacheSaverMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(
            cacheSaverMock.invokedAsyncProcessParameters?.data.urlRequest,
            response.request
        )
        XCTAssertEqual(unwrappedResult, expectedCacheResult)
    }
    
    func testAsyncProcess_withCancelTask_beforeStart_thenCancellationErrorReceived() async throws {
        // given
        
        let url = URL(string: "http://UrlETagUrlCacheTriggerNode.test/testNextCAlledIfDataIsNotNotModified")!
        let response = Utils.getMockURLDataResponse(url: url, statusCode: 304)
        cacheSaverMock.stubbedAsyncProccessResult = .success([:])
        
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
        
        let url = URL(string: "http://UrlETagUrlCacheTriggerNode.test/testNextCAlledIfDataIsNotNotModified")!
        let response = Utils.getMockURLDataResponse(url: url, statusCode: 304)
        cacheSaverMock.stubbedAsyncProcessRunFunction = {
            try? await Task.sleep(nanoseconds: 3 * 1000 * 1000)
        }
        cacheSaverMock.stubbedAsyncProccessResult = .success([:])
        
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
