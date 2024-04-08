//
//  VoidOutputNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class VoidOutputNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<Json, Json>!
    private var logContextMock: LoggingContextMock!
    private var dtoEncodableMock: DTOEncodableMock<Json>!
    
    // MARK: - Sut
    
    private var sut: VoidOutputNode<DTOEncodableMock<Json>>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        dtoEncodableMock = DTOEncodableMock()
        sut = VoidOutputNode(next: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        dtoEncodableMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_withDTOConvertionError_thenNextDidNotCalled() async {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .failure(MockError.firstError)
        
        // when
        
        _ = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_withDTOConvertionError_thenErrorReceived() async throws {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .firstError)
    }
    
    func testAsyncProcess_withDTOConvertionSuccess_thenNextCalled() async throws {
        // given
        
        let expectedJson = ["TestJsonKey": "TestJsonValue"]
        dtoEncodableMock.stubbedToDTOResult = .success(expectedJson)
        nextNodeMock.stubbedAsyncProccessResult = .success([:])
        
        // when
        
        _ = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let json = try XCTUnwrap(input as? [String: String])
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(json, expectedJson)
    }
    
    func testAsyncProcess_whenNextNodeReturnsError_thenLogDidNotCalled() async {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .success([:])
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        
        // when
        
        _ = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let invokedAdd = await logContextMock.invokedAdd
        XCTAssertFalse(invokedAdd)
    }
    
    func testAsyncProcess_whenNextNodeReturnsError_thenErrorReceived() async throws {
        // given
        
        dtoEncodableMock.stubbedToDTOResult = .success([:])
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        
        // when
        
        let result = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .secondError)
    }
    
    func testAsyncProcess_whenNextNodeReturnsSuccess_thenSuccessReceived() async throws {
        // given
        
        let expectedJson = ["TestJsonKey": "TestJsonValue"]
        dtoEncodableMock.stubbedToDTOResult = .success([:])
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedJson)
        
        // when
        
        let result = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        XCTAssertNotNil(result.value)
    }
    
    func testAsyncProcess_whenNextNodeReturnsSuccess_thenLogCalled() async throws {
        // given
        
        let json = ["TestJsonKey": "TestJsonValue"]
        dtoEncodableMock.stubbedToDTOResult = .success([:])
        nextNodeMock.stubbedAsyncProccessResult = .success(json)
        
        var expectedLog = Log(sut.logViewObjectName, id: sut.objectName, order: LogOrder.voidOutputNode)
        expectedLog += "VoidOutputNode used but request have not empty response" + .lineTabDeilimeter
        expectedLog += "\(json)"
        
        
        // when
        
        _ = await sut.process(dtoEncodableMock, logContext: logContextMock)
        
        // then
        
        let invokedAddCount = await logContextMock.invokedAddCount
        let parameter = await logContextMock.invokedAddParameter
        let log = try XCTUnwrap(parameter)
        
        XCTAssertEqual(invokedAddCount, 1)
        XCTAssertEqual(log.description, expectedLog.description)
    }
}
