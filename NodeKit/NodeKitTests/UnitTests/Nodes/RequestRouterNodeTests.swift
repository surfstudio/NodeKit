//
//  RequestRouterNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class RequestRouterNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<RoutableRequestModel<Int, Int>, Int>!
    private var logContextMock: LoggingContextMock!
    private var stubbedRoute: Int!
    
    // MARK: - Sut
    
    private var sut: RequestRouterNode<Int, Int, Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        stubbedRoute = 001
        sut = RequestRouterNode(next: nextNodeMock, route: stubbedRoute)
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        stubbedRoute = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_thenNextCalled() async throws {
        // given
        
        let model = RequestModel(metadata: ["TestMetadataKey": "TestMetadataValue"], raw: 002)
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.route, stubbedRoute)
        XCTAssertEqual(input.metadata, model.metadata)
        XCTAssertEqual(input.raw, model.raw)
    }
    
    func testAsyncProcess_whenNextReturnsSuccess_thenSuccessReceived() async throws {
        // given
        
        let expectedResult = 003
        let model = RequestModel(metadata: [:], raw: 1)
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_whenNextFailureSuccess_thenFailureReceived() async throws {
        // given
        
        let model = RequestModel(metadata: [:], raw: 1)
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .secondError)
    }
    
    func testAsyncProcess_withCancelTask_beforeStart_thenCancellationErrorReceived() async throws {
        // given
        
        let model = RequestModel(metadata: [:], raw: 1)
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        let task = Task {
            try? await Task.sleep(nanoseconds: 100 * 1000)
            return await sut.process(model, logContext: logContextMock)
        }
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
    
    func testAsyncProcess_withCancelTask_afterStart_thenCancellationErrorReceived() async throws {
        // given
        
        let model = RequestModel(metadata: [:], raw: 1)
        
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        nextNodeMock.stubbedAsyncProcessRunFunction = {
            try? await Task.sleep(nanoseconds: 3 * 1000 * 1000)
        }
        
        // when
        
        let task = Task {
            await sut.process(model,logContext: logContextMock)
        }
        
        try? await Task.sleep(nanoseconds: 100 * 1000)
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
}
