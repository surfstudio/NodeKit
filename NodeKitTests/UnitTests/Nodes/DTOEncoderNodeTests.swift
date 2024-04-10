//
//  DTOEncoderNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class DTOEncoderNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<RawEncodableMock<Int>, Int>!
    private var logContextMock: LoggingContextMock!
    private var dtoEncodableMock: DTOEncodableMock<RawEncodableMock<Int>>!
    private var rawEncodableMock: RawEncodableMock<Int>!
    
    // MARK: - Sut
    
    private var sut: DTOEncoderNode<DTOEncodableMock<RawEncodableMock<Int>>, Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        rawEncodableMock = RawEncodableMock()
        dtoEncodableMock = DTOEncodableMock()
        sut = DTOEncoderNode(rawEncodable: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_withDTOConvertationError_thenNextNodeDidNotCall() async {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .failure(MockError.firstError)
        
        // when
        
        _ = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_withDTOConvertationError_thenErrorReceived() async throws {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        XCTAssertEqual(error, .firstError)
    }
    
    func testAsyncProcess_withSuccessDTOConvertation_thenNextNodeCalled() async throws {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .success(rawEncodableMock)
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        XCTAssertTrue(input === rawEncodableMock)
    }
    
    func testAsyncProcess_withSuccessResult_thenSuccessReceived() async throws {
        // given
        
        let expectedResult = 80
        
        dtoEncodableMock.stubbedToDTOResult = .success(rawEncodableMock)
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withFailureResult_thenFailureReceived() async throws {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .success(rawEncodableMock)
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.thirdError)
        
        // when
        
        let result = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        XCTAssertEqual(error, .thirdError)
    }
}
