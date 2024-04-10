//
//  MetadataConnectorNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class MetadataConnectorNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<RequestModel<Int>, Int>!
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
    
    func testAsyncProcess_withMetadata_thenNextCalled() async throws {
        // given
        
        let expectedInput = 5
        let expectedMetadata = ["TestMetadataKey": "TestMetadataValue"]
        let sut = MetadataConnectorNode(next: nextNodeMock, metadata: expectedMetadata)
        
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(expectedInput, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.metadata, expectedMetadata)
        XCTAssertEqual(input.raw, expectedInput)
    }
    
    func testAsyncProcess_withoutMetadata_thenNextCalled() async throws {
        // given
        
        let expectedInput = 86
        let sut = MetadataConnectorNode(next: nextNodeMock, metadata: [:])
        
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(expectedInput, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.metadata, [:])
        XCTAssertEqual(input.raw, expectedInput)
    }
    
    func testAsyncProcess_nextReturnsSuccess_thenSuccessReceived() async throws {
        // given
        
        let expectedResult = 0012
        let sut = MetadataConnectorNode(next: nextNodeMock, metadata: [:])
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(1, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_nextReturnsError_thenErrorReceived() async throws {
        // given
        
        let sut = MetadataConnectorNode(next: nextNodeMock, metadata: [:])
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(1, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .firstError)
    }
}
