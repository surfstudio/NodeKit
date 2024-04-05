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
    
    func testAsyncProcess_withSuccessResult_thenCorrectModelBuilded_andSuccessResultReceived() async throws {
        // given
        
        let expectedEncoding = 49
        let expectedMetadata = ["TestMetadataKey": "TestMetadataValue"]
        let expectedRaw = 42
        let expectedRoute = 90
        let sut = RequestEncoderNode(next: nextNodeMock, encoding: expectedEncoding)
        let expectedResult = 100
        let model = RoutableRequestModel<Int, Int>(
            metadata: expectedMetadata,
            raw: expectedRaw,
            route: expectedRoute
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // then
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.encoding, expectedEncoding)
        XCTAssertEqual(input.metadata, expectedMetadata)
        XCTAssertEqual(input.raw, expectedRaw)
        XCTAssertEqual(input.route, expectedRoute)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withFailureResult_thenCorrectModelBuilded_andFailureResultReceived() async throws {
        // given
        
        let expectedEncoding = 49
        let expectedMetadata = ["TestMetadataKey": "TestMetadataValue"]
        let expectedRaw = 42
        let expectedRoute = 90
        let sut = RequestEncoderNode(next: nextNodeMock, encoding: expectedEncoding)
        let expectedResult = 100
        let model = RoutableRequestModel<Int, Int>(
            metadata: expectedMetadata,
            raw: expectedRaw,
            route: expectedRoute
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        
        // then
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.encoding, expectedEncoding)
        XCTAssertEqual(input.metadata, expectedMetadata)
        XCTAssertEqual(input.raw, expectedRaw)
        XCTAssertEqual(input.route, expectedRoute)
        XCTAssertEqual(error, .secondError)
    }
}
