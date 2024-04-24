//
//  RequestEncoderNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class RequestEncoderNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<EncodableRequestModel<Int, Int, Int>, Int>!
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
    
    func testAsyncProcess_withSuccessResult_thenCorrectModelBuilded() async throws {
        // given
        
        let expectedEncoding = 49
        let expectedMetadata = ["TestMetadataKey": "TestMetadataValue"]
        let expectedRaw = 42
        let expectedRoute = 90
        let sut = RequestEncoderNode(next: nextNodeMock, encoding: expectedEncoding)
        let model = RoutableRequestModel<Int, Int>(
            metadata: expectedMetadata,
            raw: expectedRaw,
            route: expectedRoute
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // then
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.encoding, expectedEncoding)
        XCTAssertEqual(input.metadata, expectedMetadata)
        XCTAssertEqual(input.raw, expectedRaw)
        XCTAssertEqual(input.route, expectedRoute)
    }
    
    func testAsyncProcess_withSuccessResult_thenSuccessReceived() async throws {
        // given
        
        let sut = RequestEncoderNode(next: nextNodeMock, encoding: 1)
        let expectedResult = 100
        let model = RoutableRequestModel<Int, Int>(
            metadata: [:],
            raw: 1,
            route: 1
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // then
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withFailureResult_thenCorrectModelBuilded() async throws {
        // given
        
        let expectedEncoding = 49
        let expectedMetadata = ["TestMetadataKey": "TestMetadataValue"]
        let expectedRaw = 42
        let expectedRoute = 90
        let sut = RequestEncoderNode(next: nextNodeMock, encoding: expectedEncoding)
        let model = RoutableRequestModel<Int, Int>(
            metadata: expectedMetadata,
            raw: expectedRaw,
            route: expectedRoute
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // then
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.encoding, expectedEncoding)
        XCTAssertEqual(input.metadata, expectedMetadata)
        XCTAssertEqual(input.raw, expectedRaw)
        XCTAssertEqual(input.route, expectedRoute)
    }
    
    func testAsyncProcess_withFailureResult_thenFailureReceived() async throws {
        // given
        
        let sut = RequestEncoderNode(next: nextNodeMock, encoding: 1)
        let model = RoutableRequestModel<Int, Int>(
            metadata: [:],
            raw: 1,
            route: 1
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.thirdError)
        
        // then
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        XCTAssertEqual(error, .thirdError)
    }
}
