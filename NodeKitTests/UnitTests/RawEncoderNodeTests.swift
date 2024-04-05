//
//  RawEncoderNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class RawEncoderNodeTests: XCTestCase {

    // MARK: - Dependecies
    
    private var rawEncodableMock: RawEncodableMock<Json>!
    private var nextNodeMock: AsyncNodeMock<Json, Int>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: RawEncoderNode<RawEncodableMock<Json>, Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        rawEncodableMock = RawEncodableMock()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = RawEncoderNode(next: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        rawEncodableMock = nil
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_whenSuccessRawEncoding_andSuccessReturns_thenNextCalledWithJsonAndSuccessReceived() async throws {
        // given
        
        let expectedResult = 21
        let expectedInput = ["name": "TestName", "value": "TestValue"]
        
        rawEncodableMock.stubbedToRawResult = .success(expectedInput)
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0 as? [String: String])
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(rawEncodableMock.invokedToRawCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input, expectedInput)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_whenSuccessRawEncoding_andFailureReturns_thenNextCalledWithJsonAndFailureReceived() async throws {
        // given
        
        let expectedInput = ["name": "TestName", "value": "TestValue"]
        
        rawEncodableMock.stubbedToRawResult = .success(expectedInput)
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        
        // when
        
        let result = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0 as? [String: String])
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(rawEncodableMock.invokedToRawCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input, expectedInput)
        XCTAssertEqual(error, .secondError)
    }
    
    func testAsyncProcess_whenErrorRawEncoding_thenNextDidNotCallAndErrorReceived() async throws {
        // given
        
        rawEncodableMock.stubbedToRawResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(rawEncodableMock.invokedToRawCount, 1)
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
        XCTAssertEqual(error, .firstError)
    }
}
