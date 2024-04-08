//
//  DTOMapperNodeTests.swift
//  IntegrationTests
//
//  Created by Aleksandr Smirnov on 22.10.2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

final class DTOMapperNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var logContextMock: LoggingContextMock!
    private var nextNodeMock: AsyncNodeMock<Json, Json>!
    
    // MARK: - Sut
    
    private var sut: DTOMapperNode<Json, UserEntry>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        logContextMock = LoggingContextMock()
        nextNodeMock = AsyncNodeMock()
        sut = DTOMapperNode(next: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        logContextMock = nil
        nextNodeMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_withErrorKey_thenCodableErrorLoggingCorrectly() async throws {
        // given
        
        let expectedInput = [
            "test": "value",
            "test2": "value2"
        ]

        nextNodeMock.stubbedAsyncProccessResult = .success([
            "id": "1",
            "name": "Francisco", // corrupted key
            "lastName": "D'Anconia"
        ])
        
        // when
        
        let result = await sut.process(expectedInput, logContext: logContextMock)
        
        // then
        
        let log = await logContextMock.invokedAddParameter
        let invokedAddLogCount = await logContextMock.invokedAddCount
        
        let logMessageId = try XCTUnwrap(log?.id)
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data as? [String: String])

        XCTAssertEqual(invokedAddLogCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input, expectedInput)
        XCTAssertNotNil(result.error as? Swift.DecodingError)
        XCTAssert(logMessageId.contains(sut.objectName))
    }
    
    func testAsyncProcess_withCorrectKey_ThatSuccessCaseNotLogging() async throws {
        // given
        
        let expectedInput = [
            "test3": "value5",
            "test4": "value6"
        ]

        nextNodeMock.stubbedAsyncProccessResult = .success([
            "id": "1",
            "firstName": "Francisco",
            "lastName": "D'Anconia"
        ])
        
        // when
        
        let result = await sut.process(expectedInput, logContext: logContextMock)
        
        // then
        
        let invokedAddLog = await logContextMock.invokedAdd
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data as? [String: String])
        let resultUser = try XCTUnwrap(result.value)

        XCTAssertFalse(invokedAddLog)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input, expectedInput)
        XCTAssertEqual(resultUser.firstName, "Francisco")
        XCTAssertEqual(resultUser.lastName, "D'Anconia")
        XCTAssertEqual(resultUser.id, "1")
    }
    
    func testAsyncProcess_withErrorAndLog_thenCodableErrorNotLoggingInsteadOtherError() async throws {
        // given
        
        let expectedInput = [
            "test7": "value9",
            "test8": "value10"
        ]
        
        var log = Log(nextNodeMock.logViewObjectName, id: nextNodeMock.objectName, order: LogOrder.dtoMapperNode)
        log += "\(BaseTechnicalError.noInternetConnection)"
        
        await logContextMock.add(log)
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(expectedInput, logContext: logContextMock)
        
        // then
        
        let invokedLog = await logContextMock.invokedAddParameter
        let invokedAddLogCount = await logContextMock.invokedAddCount
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data as? [String: String])
        let error = try XCTUnwrap(result.error as? MockError)
        let logMessageId = try XCTUnwrap(invokedLog?.id)

        XCTAssertEqual(invokedAddLogCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input, expectedInput)
        XCTAssertFalse(logMessageId.contains(sut.objectName))
        XCTAssert(logMessageId.contains(nextNodeMock.objectName))
        XCTAssertEqual(error, .firstError)
    }
    
    func testAsyncProcess_withEncodeError_thenErrorAndLogReceived() async throws {
        // given
        
        struct TestStruct: RawEncodable {
            typealias Raw = Json
            
            let test1 = 0
            let test2 = "2"
            
            func toRaw() throws -> Raw {
                throw MockError.secondError
            }
        }
        
        let sut = DTOMapperNode<TestStruct, UserEntry>(next: nextNodeMock)
        nextNodeMock.stubbedAsyncProccessResult = .success([:])
        
        // when
        
        let result = await sut.process(TestStruct(),logContext: logContextMock)
        
        // then
        
        let invokedLog = await logContextMock.invokedAddParameter
        let invokedAddLogCount = await logContextMock.invokedAddCount
        let logMessageId = try XCTUnwrap(invokedLog?.id)
        let error = try XCTUnwrap(result.error as? MockError)

        XCTAssertEqual(invokedAddLogCount, 1)
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
        XCTAssertTrue(logMessageId.contains(sut.objectName))
        XCTAssertFalse(logMessageId.contains(nextNodeMock.objectName))
        XCTAssertEqual(error, .secondError)
    }
}
