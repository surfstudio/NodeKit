//
//  VoidIONodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class VoidIONodeTest: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<Json, Json>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: VoidIONode!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = VoidIONode(next: nextNodeMock)
    }
    
    override func tearDown() {
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_withEmptyResponse_thenLogDidNotCall() async {
        // given
        
        nextNodeMock.stubbedAsyncProccessResult = .success([:])
        
        // when
        
        _ = await sut.process((), logContext: logContextMock)
        
        // when
        
        let invokedAdd = await logContextMock.invokedAdd
        
        XCTAssertFalse(invokedAdd)
    }
    
    func testAsyncProcess_withEmptyResponse_thenNextCalled() async {
        // given
        
        nextNodeMock.stubbedAsyncProccessResult = .success([:])
        
        // when
        
        _ = await sut.process((), logContext: logContextMock)
        
        // when
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
    }
    
    func testAsyncProcess_withEmptyResponse_thenSuccessReceived() async {
        // given
        
        nextNodeMock.stubbedAsyncProccessResult = .success([:])
        
        // when
        
        let result = await sut.process((), logContext: logContextMock)
        
        // when
        
        XCTAssertNotNil(result.value)
    }
    
    func testAsyncProcess_nonEmptyResponse_thenLogCalled() async throws {
        // given
        
        let json: Json = ["TestKey": "TestValue"]
        var expectedLog  = Log(sut.logViewObjectName, id: sut.objectName, order: LogOrder.voidIONode)
        
        expectedLog += "VoidIOtNode used but request have not empty response" + .lineTabDeilimeter
        expectedLog += "\(json)"
        
        
        nextNodeMock.stubbedAsyncProccessResult = .success(json)
        
        // when
        
        _ = await sut.process((), logContext: logContextMock)
        
        // when
        
        let invokedAddCount = await logContextMock.invokedAddCount
        let input = await logContextMock.invokedAddParameter
        let log = try XCTUnwrap(input)
        
        XCTAssertEqual(invokedAddCount, 1)
        XCTAssertEqual(log.description, expectedLog.description)
    }
    
    func testAsyncProcess_nonEmptyResponse_thenNextCalled() async throws {
        // given
        
        nextNodeMock.stubbedAsyncProccessResult = .success(["TestKey": "TestValue"])
        
        // when
        
        _ = await sut.process((), logContext: logContextMock)
        
        // when
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
    }
    
    func testAsyncProcess_nonEmptyResponse_thenSuccessReceived() async throws {
        // given
        
        nextNodeMock.stubbedAsyncProccessResult = .success(["TestKey": "TestValue"])
        
        // when
        
        let result = await sut.process((), logContext: logContextMock)
        
        // when
        
        XCTAssertNotNil(result.value)
    }
    
    func testAsyncProcess_withFailureResponse_thenLogDidNotCall() async {
        // given
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        _ = await sut.process((), logContext: logContextMock)
        
        // when
        
        let invokedAdd = await logContextMock.invokedAdd
        
        XCTAssertFalse(invokedAdd)
    }
    
    func testAsyncProcess_withFailureResponse_thenNextCalled() async {
        // given
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        _ = await sut.process((), logContext: logContextMock)
        
        // when
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
    }
    
    func testAsyncProcess_withFailureResponse_thenErrorReceived() async throws {
        // given
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process((), logContext: logContextMock)
        
        // when
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .firstError)
    }
}
