//
//  ModelInputNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class ModelInputNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<RawEncodableMock<Int>, DTODecodableMock.DTO>!
    private var logContextMock: LoggingContextMock!
    private var rawEncodableMock: RawEncodableMock<Int>!
    private var dtoDecodableMock: DTODecodableMock!
    private var rawDecodableMock: RawDecodableMock!
    private var dtoEncodableMock: DTOEncodableMock<RawEncodableMock<Int>>!
    
    // MARK: - Sut
    
    private var sut: ModelInputNode<DTOEncodableMock<RawEncodableMock<Int>>, DTODecodableMock>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        rawEncodableMock = RawEncodableMock()
        dtoDecodableMock = DTODecodableMock()
        rawDecodableMock = RawDecodableMock()
        dtoEncodableMock = DTOEncodableMock()
        sut = ModelInputNode(next: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        rawEncodableMock = nil
        dtoDecodableMock = nil
        rawDecodableMock = nil
        sut = nil
        RawDecodableMock.flush()
        DTODecodableMock.flush()
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_thenToDTOCalled() async {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .failure(MockError.firstError)
        
        // when
        
        _ = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        XCTAssertEqual(dtoEncodableMock.invokedToDTOCount, 1)
    }
    
    func testAsyncProcess_withDTOConvertaionError_thenNextDidNotCall() async {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .failure(MockError.firstError)
        
        // when
        
        _ = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_withDTOConvertaionError_thenErrorReceived() async throws {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .firstError)
    }
    
    func testAsyncProcess_withDTOConvertaionSuccess_thenNextCalled() async throws {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .success(rawEncodableMock)
        rawEncodableMock.stubbedToRawResult = .success(1)
        DTODecodableMock.stubbedFromResult = .success(dtoDecodableMock)
        
        nextNodeMock.stubbedAsyncProccessResult = .success(rawDecodableMock)
        
        // when
        
        _ = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertTrue(input === rawEncodableMock)
    }
    
    func testAsyncProcess_whenNextReturnsFailure_thenDTODecodableDidNotCall() async {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .success(rawEncodableMock)
        rawEncodableMock.stubbedToRawResult = .success(1)
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        
        // when
        
        _ = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(DTODecodableMock.invokedFrom)
    }
    
    func testAsyncProcess_whenNextReturnsFailure_thenFailureReceived() async throws {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .success(rawEncodableMock)
        rawEncodableMock.stubbedToRawResult = .success(1)
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        
        // when
        
        let result = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .secondError)
    }
    
    func testAsyncProcess_whenNextReturnsSuccess_thenDTODecodableCalled() async throws {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .success(rawEncodableMock)
        rawEncodableMock.stubbedToRawResult = .success(1)
        
        nextNodeMock.stubbedAsyncProccessResult = .success(rawDecodableMock)
        DTODecodableMock.stubbedFromResult = .success(dtoDecodableMock)
        
        // when
        
        _ = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(DTODecodableMock.invokedFromParameter)
        
        XCTAssertEqual(DTODecodableMock.invokedFromCount, 1)
        XCTAssertTrue(input === rawDecodableMock)
    }
    
    func testAsyncProcess_withDTODecodableError_thenErrorReceived() async throws {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .success(rawEncodableMock)
        rawEncodableMock.stubbedToRawResult = .success(1)
        
        nextNodeMock.stubbedAsyncProccessResult = .success(rawDecodableMock)
        DTODecodableMock.stubbedFromResult = .failure(MockError.thirdError)
        
        // when
        
        let result = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .thirdError)
    }
    
    func testAsyncProcess_withDTODecodableSuccess_thenSuccessReceived() async throws {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .success(rawEncodableMock)
        rawEncodableMock.stubbedToRawResult = .success(1)
        
        nextNodeMock.stubbedAsyncProccessResult = .success(rawDecodableMock)
        DTODecodableMock.stubbedFromResult = .success(dtoDecodableMock)
        
        // when
        
        let result = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertTrue(value === dtoDecodableMock)
    }
}
