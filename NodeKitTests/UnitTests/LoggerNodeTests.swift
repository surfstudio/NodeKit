//
//  LoggerNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class LoggerNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<Int, Int>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: LoggerNode<Int, Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = LoggerNode(next: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProccess_thenNextCalled() async throws {
        // given
        
        let expectedInput = 00942
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(expectedInput, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input, expectedInput)
    }
    
    func testAsyncProccess_whenNextNodeReturnsSuccess_thenSuccessReceived() async throws {
        // given
        
        let expectedResult = 001238
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(1, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProccess_whenNextNodeReturnsFailure_thenFailureReceived() async throws {
        // given
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.process(1, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(error, .firstError)
    }
}
