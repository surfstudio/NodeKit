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

    func testProcessLegacy_withErrorKey_thenCodableErrorLoggingCorrectly() throws {
        // given
        
        let expectedInput = [
            "test": "value",
            "test2": "value2"
        ]

        nextNodeMock.stubbedProccessLegacyResult = .emit(data: [
            "id": "1",
            "name": "Francisco", // corrupted key
            "lastName": "D'Anconia"
        ])
        
        var resultError: Error?
        
        let exp = expectation(description: "\(#function)")
        
        // when
        
        let result = sut.processLegacy(expectedInput).onError { error in
            resultError = error
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
        
        // then
        
        let logMessageId = try XCTUnwrap(result.log?.id)
        let input = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter as? [String: String])

        XCTAssertEqual(nextNodeMock.invokedProcessLegacyCount, 1)
        XCTAssertEqual(input, expectedInput)
        XCTAssertNotNil(resultError as? Swift.DecodingError)
        XCTAssert(logMessageId.contains(sut.objectName))
    }
    
    func testProcessLegacy_withCorrectKey_ThatSuccessCaseNotLogging() throws {
        // given
        
        let expectedInput = [
            "test3": "value5",
            "test4": "value6"
        ]
        let exp = expectation(description: "\(#function)")

        nextNodeMock.stubbedProccessLegacyResult = .emit(data: [
            "id": "1",
            "firstName": "Francisco",
            "lastName": "D'Anconia"
        ])
        
        var resultUser: UserEntry?
        var resultError: Error?
        
        // when
        
        let result = sut.processLegacy(expectedInput).onCompleted { user in
            resultUser = user
            exp.fulfill()
        }.onError { error in
            resultError = error
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter as? [String: String])

        XCTAssertEqual(nextNodeMock.invokedProcessLegacyCount, 1)
        XCTAssertEqual(input, expectedInput)
        XCTAssertNotNil(resultUser)
        XCTAssertNil(resultError)
        XCTAssertNil(result.log)
    }
    
    func testProcessLegacy_withErrorAndLog_thenCodableErrorNotLoggingInsteadOtherError() throws {
        // given
        
        let expectedInput = [
            "test7": "value9",
            "test8": "value10"
        ]
        let exp = expectation(description: "\(#function)")
        let context = Context<Json>()
        
        nextNodeMock.stubbedProccessLegacyResult = context
        
        var resultError: Error?
        var log = Log(nextNodeMock.logViewObjectName, id: nextNodeMock.objectName, order: LogOrder.dtoMapperNode)
        log += "\(BaseTechnicalError.noInternetConnection)"
        
        context
            .emit(error: BaseTechnicalError.noInternetConnection)
            .log(log)
        
        // when
        
        let result = sut.processLegacy(expectedInput).onError { error in
            resultError = error
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter as? [String: String])
        let error = try XCTUnwrap(resultError as? BaseTechnicalError)
        let logMessageId = try XCTUnwrap(result.log?.id)

        XCTAssertEqual(nextNodeMock.invokedProcessLegacyCount, 1)
        XCTAssertEqual(input, expectedInput)
        XCTAssertFalse(logMessageId.contains(sut.objectName))
        XCTAssert(logMessageId.contains(nextNodeMock.objectName))
        XCTAssertEqual(error, .noInternetConnection)
    }
    
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
