//
//  IfConnectionFailedFromCacheNodeTests.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 31/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

public class IfConnectionFailedFromCacheNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var logContextMock: LoggingContextMock!
    private var cacheReaderNodeMock: AsyncNodeMock<UrlNetworkRequest, Json>!
    private var mapperNode: TechnicaErrorMapperNode!
    private var mapperNextNodeMock: AsyncNodeMock<URLRequest, Json>!
    
    // MARK: - Sut
    
    private var sut: IfConnectionFailedFromCacheNode!
    
    // MARK: - Lifecycle
    
    public override func setUp() {
        super.setUp()
        logContextMock = LoggingContextMock()
        cacheReaderNodeMock = AsyncNodeMock()
        mapperNextNodeMock = AsyncNodeMock()
        mapperNode = TechnicaErrorMapperNode(next: mapperNextNodeMock)
        sut = IfConnectionFailedFromCacheNode(next: mapperNode, cacheReaderNode: cacheReaderNodeMock)
    }
    
    public override func tearDown() {
        super.tearDown()
        logContextMock = nil
        cacheReaderNodeMock = nil
        mapperNextNodeMock = nil
        mapperNode = nil
        sut = nil
    }
    
    // MARK: - Tests

    public func testProcess_whenErrorReceived_thenNodeWorkInCaseOfBadInternet() {
        // given
        
        let request = URLRequest(url: URL(string: "test.ex.temp")!)
        
        mapperNextNodeMock.stubbedProccessLegacyResult = .emit(error: NSError(domain: "app.network", code: -1009, userInfo: nil))
        cacheReaderNodeMock.stubbedProccessLegacyResult = .emit(data: Json())

        // when

        _ = sut.processLegacy(request)

        // then

        XCTAssertEqual(mapperNextNodeMock.invokedProcessLegacyCount, 1)
        XCTAssertEqual(cacheReaderNodeMock.invokedProcessLegacyCount, 1)
    }
    
    public func testProcess_withoutError_thenNodeWorkInCaseOfGoodInternet() {
        // given
        
        let request = URLRequest(url: URL(string: "test.ex.temp")!)
        
        mapperNextNodeMock.stubbedProccessLegacyResult = .emit(data: Json())
        cacheReaderNodeMock.stubbedProccessLegacyResult = .emit(data: Json())

        // when

        _ = sut.processLegacy(request)

        // then

        XCTAssertEqual(mapperNextNodeMock.invokedProcessLegacyCount, 1)
        XCTAssertEqual(cacheReaderNodeMock.invokedProcessLegacyCount, 0)
    }
    
    public func testAsyncProcess_whenErrorReceived_thenNodeWorkInCaseOfBadInternet() async throws {
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
        XCTAssertEqual(mapperNextNodeMock.invokedAsyncProcessParameter?.0, request)
        XCTAssertEqual(cacheReaderNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(cacheReaderNodeMock.invokedAsyncProcessParameter?.0.urlRequest, request)
        XCTAssertEqual(unwrappedResult, expectedResult)
    }
    
    public func testAsyncProcess_withCustomError_thenCustomErrorReceived() async throws {
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
        XCTAssertEqual(mapperNextNodeMock.invokedAsyncProcessParameter?.0, request)
        XCTAssertFalse(cacheReaderNodeMock.invokedAsyncProcess)
        XCTAssertEqual(error, .secondError)
    }
    
    public func testAsyncProcess_withoutError_thenNodeWorkInCaseOfGoodInternet() async throws {
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
        XCTAssertEqual(mapperNextNodeMock.invokedAsyncProcessParameter?.0, request)
        XCTAssertFalse(cacheReaderNodeMock.invokedAsyncProcess)
        XCTAssertEqual(unwrappedResult, expectedResult)
    }
}
