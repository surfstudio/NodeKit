//
//  IfConnectionFailedFromCacheNodeTests.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 31/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Foundation
import XCTest

final class IfConnectionFailedFromCacheNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var logContextMock: LoggingContextMock!
    private var cacheReaderNodeMock: AsyncNodeMock<UrlNetworkRequest, Json>!
    private var mapperNode: TechnicaErrorMapperNode!
    private var mapperNextNodeMock: AsyncNodeMock<URLRequest, Json>!
    
    // MARK: - Sut
    
    private var sut: IfConnectionFailedFromCacheNode!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        logContextMock = LoggingContextMock()
        cacheReaderNodeMock = AsyncNodeMock()
        mapperNextNodeMock = AsyncNodeMock()
        mapperNode = TechnicaErrorMapperNode(next: mapperNextNodeMock)
        sut = IfConnectionFailedFromCacheNode(next: mapperNode, cacheReaderNode: cacheReaderNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        logContextMock = nil
        cacheReaderNodeMock = nil
        mapperNextNodeMock = nil
        mapperNode = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_whenErrorReceived_thenNodeWorkInCaseOfBadInternet() async throws {
        // given
        
        let request = URLRequest(url: URL(string: "test.ex.temp")!)
        let expectedResult = ["test": "value"]
        
        mapperNextNodeMock.stubbedAsyncProccessResult = .failure(NSError(domain: "app.network", code: -1009, userInfo: nil))
        cacheReaderNodeMock.stubbedAsyncProccessResult = .success(expectedResult)

        // when

        let result = await sut.process(request, logContext: logContextMock)

        // then

        let unwrappedResult = try XCTUnwrap(result.get() as? [String: String])
        XCTAssertEqual(mapperNextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(mapperNextNodeMock.invokedAsyncProcessParameters?.data, request)
        XCTAssertEqual(cacheReaderNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(cacheReaderNodeMock.invokedAsyncProcessParameters?.data.urlRequest, request)
        XCTAssertEqual(unwrappedResult, expectedResult)
    }
    
    func testAsyncProcess_withCustomError_thenCustomErrorReceived() async throws {
        // given
        
        let request = URLRequest(url: URL(string: "test.ex.temp")!)
        let expectedResult = ["test": "value"]
        
        mapperNextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        cacheReaderNodeMock.stubbedAsyncProccessResult = .success(expectedResult)

        // when

        let result = await sut.process(request, logContext: logContextMock)

        // then

        let error = try XCTUnwrap(result.error as? MockError)
        XCTAssertEqual(mapperNextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(mapperNextNodeMock.invokedAsyncProcessParameters?.data, request)
        XCTAssertFalse(cacheReaderNodeMock.invokedAsyncProcess)
        XCTAssertEqual(error, .secondError)
    }
    
    func testAsyncProcess_withoutError_thenNodeWorkInCaseOfGoodInternet() async throws {
        // given
        
        let request = URLRequest(url: URL(string: "test.ex.temp")!)
        let expectedResult = ["test2": "value2"]
        
        mapperNextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        cacheReaderNodeMock.stubbedAsyncProccessResult = .success(["test1": "value1"])

        // when

        let result = await sut.process(request, logContext: logContextMock)

        // then

        let unwrappedResult = try XCTUnwrap(result.get() as? [String: String])
        XCTAssertEqual(mapperNextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(mapperNextNodeMock.invokedAsyncProcessParameters?.data, request)
        XCTAssertFalse(cacheReaderNodeMock.invokedAsyncProcess)
        XCTAssertEqual(unwrappedResult, expectedResult)
    }
}
