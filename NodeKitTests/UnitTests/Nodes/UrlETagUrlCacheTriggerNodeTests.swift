//
//  UrlETagUrlCacheTriggerNodeTests.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Foundation
import XCTest

final class UrlETagUrlCacheTriggerNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var transportNodeMock: AsyncNodeMock<UrlDataResponse, Json>!
    private var cacheSaverMock: AsyncNodeMock<UrlNetworkRequest, Json>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: UrlNotModifiedTriggerNode!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        transportNodeMock = AsyncNodeMock()
        cacheSaverMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = UrlNotModifiedTriggerNode(next: transportNodeMock, cacheReader: cacheSaverMock)
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
        let response = Utils.getMockUrlDataResponse(url: url)
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
        let response = Utils.getMockUrlDataResponse(url: url, statusCode: 304)
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
}