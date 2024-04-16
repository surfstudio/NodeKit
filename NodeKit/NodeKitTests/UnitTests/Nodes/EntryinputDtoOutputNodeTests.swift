//
//  EntryinputDtoOutputNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class EntryInputDtoOutputNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<RawEncodableMock<Int>.Raw, RawDecodableMock.Raw>!
    private var logContextMock: LoggingContextMock!
    private var rawEncodableMock: RawEncodableMock<Int>!
    private var dtoDecodableMock: DTODecodableMock!
    private var rawDecodableMock: RawDecodableMock!
    
    // MARK: - Sut
    
    private var sut: EntryInputDtoOutputNode<RawEncodableMock<Int>, DTODecodableMock>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        rawEncodableMock = RawEncodableMock()
        dtoDecodableMock = DTODecodableMock()
        rawDecodableMock = RawDecodableMock()
        sut = EntryInputDtoOutputNode(next: nextNodeMock)
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
    
    func testAsyncProcess_withToRawConvertionFailure_thenNextNodeDidNotCall() async {
        // given
        
        rawEncodableMock.stubbedToRawResult = .failure(MockError.firstError)
        
        // when
        
        _ = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        XCTAssertEqual(rawEncodableMock.invokedToRawCount, 1)
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_withToRawConvertionFailure_thenErrorReceived() async throws {
        // given
        
        rawEncodableMock.stubbedToRawResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .firstError)
    }
    
    func testAsyncProcess_withToRawConvertionSuccess_thenNextCalled() async throws {
        // given
        
        let expectedInput = 66
        
        rawEncodableMock.stubbedToRawResult = .success(expectedInput)
        nextNodeMock.stubbedAsyncProccessResult = .success([:])
        
        RawDecodableMock.stubbedFromResult = .success(rawDecodableMock)
        DTODecodableMock.stubbedFromResult = .success(dtoDecodableMock)
        
        // when
        
        _ = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(rawEncodableMock.invokedToRawCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input, expectedInput)
    }
    
    func testAsyncProcess_withToRawConvertionSuccess_thenDTOFromCalled() async throws {
        // given
        
        let expectedInput = ["TestKey": "TestValue"]
        
        rawEncodableMock.stubbedToRawResult = .success(1)
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedInput)
        
        RawDecodableMock.stubbedFromResult = .success(rawDecodableMock)
        DTODecodableMock.stubbedFromResult = .success(dtoDecodableMock)
        
        // when
        
        _ = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(RawDecodableMock.invokedFromParameter as? [String: String])
        
        XCTAssertEqual(RawDecodableMock.invokedFromCount, 1)
        XCTAssertEqual(input, expectedInput)
    }
    
    func testAsyncProcess_whenDTOFromReturnsFailure_thenOutputFromDidNotCall() async {
        // given
        
        rawEncodableMock.stubbedToRawResult = .success(1)
        nextNodeMock.stubbedAsyncProccessResult = .success([:])
        
        RawDecodableMock.stubbedFromResult = .failure(MockError.secondError)
        DTODecodableMock.stubbedFromResult = .success(dtoDecodableMock)
        
        // when
        
        _ = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        XCTAssertEqual(RawDecodableMock.invokedFromCount, 1)
        XCTAssertFalse(DTODecodableMock.invokedFrom)
    }
    
    func testAsyncProcess_whenDTOFromReturnsFailure_thenErrorReceived() async throws {
        // given
        
        rawEncodableMock.stubbedToRawResult = .success(1)
        nextNodeMock.stubbedAsyncProccessResult = .success([:])

        RawDecodableMock.stubbedFromResult = .failure(MockError.secondError)
        DTODecodableMock.stubbedFromResult = .success(dtoDecodableMock)
        
        // when
        
        let result = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .secondError)
    }
    
    func testAsyncProcess_whenDTOFromReturnsSuccess_thenOutputFromCalled() async throws {
        // given
        
        rawEncodableMock.stubbedToRawResult = .success(1)
        nextNodeMock.stubbedAsyncProccessResult = .success([:])
        
        RawDecodableMock.stubbedFromResult = .success(rawDecodableMock)
        DTODecodableMock.stubbedFromResult = .success(dtoDecodableMock)
        
        // when
        
        _ = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(DTODecodableMock.invokedFromParameter)
        
        XCTAssertEqual(DTODecodableMock.invokedFromCount, 1)
        XCTAssertTrue(input === rawDecodableMock)
    }
    
    func testAsyncProcess_whenOutputFromReturnsError_thenErrorReceived() async throws {
        // given
        
        rawEncodableMock.stubbedToRawResult = .success(1)
        nextNodeMock.stubbedAsyncProccessResult = .success([:])
        
        RawDecodableMock.stubbedFromResult = .success(rawDecodableMock)
        DTODecodableMock.stubbedFromResult = .failure(MockError.thirdError)
        
        // when
        
        let result = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .thirdError)
    }
    
    func testAsyncProcess_whenOutputFromReturnsSuccess_thenSuccess() async throws {
        // given
        
        rawEncodableMock.stubbedToRawResult = .success(1)
        nextNodeMock.stubbedAsyncProccessResult = .success([:])
        
        RawDecodableMock.stubbedFromResult = .success(rawDecodableMock)
        DTODecodableMock.stubbedFromResult = .success(dtoDecodableMock)
        
        // when
        
        let result = await sut.process(rawEncodableMock, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertTrue(value === dtoDecodableMock)
    }
}
