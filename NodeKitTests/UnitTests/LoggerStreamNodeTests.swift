//
//  LoggerStreamNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class LoggerStreamNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncStreamNodeMock<Int, Int>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: LoggerStreamNode<Int, Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncStreamNodeMock()
        logContextMock = LoggingContextMock()
        sut = LoggerStreamNode(next: nextNodeMock)
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
        nextNodeMock.stubbedAsyncStreamProccessResult = {
            AsyncStream { continuation in
                continuation.yield(.success(100))
                continuation.finish()
            }
        }
        
        // when
        
        for await _ in sut.process(expectedInput, logContext: logContextMock) { }
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncStreamProcessParameter?.data)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncStreamProcessCount, 1)
        XCTAssertEqual(input, expectedInput)
    }
    
    func testAsyncProccess_thenResultsReceived() async {
        // given
        
        let expectedResults: [NodeResult<Int>] = [
            .failure(MockError.secondError),
            .success(0013),
            .success(00312),
            .failure(MockError.firstError),
            .failure(MockError.thirdError)
        ]
        nextNodeMock.stubbedAsyncStreamProccessResult = {
            AsyncStream { continuation in
                expectedResults.forEach {
                    continuation.yield($0)
                }
                continuation.finish()
            }
        }
        
        var results: [NodeResult<Int>] = []
        
        // when
        
        for await result in sut.process(1, logContext: logContextMock) {
            results.append(result)
        }
        
        // then
        
        XCTAssertEqual(results.map { $0.castToMockError() }, expectedResults.map { $0.castToMockError() })
    }
}
