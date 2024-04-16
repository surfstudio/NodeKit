//
//  FirstCachePolicyTests.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 24/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

final class FirstCachePolicyTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<RawUrlRequest, Json>!
    private var readerNodeMock: AsyncNodeMock<UrlNetworkRequest, Json>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: FirstCachePolicyNode!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        readerNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = FirstCachePolicyNode(cacheReaderNode: readerNodeMock, next: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        readerNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testProcess_whenBadInput_thenNextCalled() {
        // given
        
        let expectation = self.expectation(description: "\(#function)")
        let request = RawUrlRequest(dataRequest: nil)
        
        var completedCalls = 0
        
        nextNodeMock.stubbedProccessResult = .emit(data: Json())

        // when

        sut.process(request).onCompleted { data in
            completedCalls += 1
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 300) { (error) in
            guard let err = error else {
                return

            }
            XCTFail("\(err)")
        }
        
        // then
        
        XCTAssertEqual(completedCalls, 1)
        XCTAssertEqual(nextNodeMock.invokedProcessCount, 1)
        XCTAssertFalse(readerNodeMock.invokedProcess)
    }
    
    func testProcess_whenGoodInput_thenReaderCalled() {
        // given
        
        let expectation = self.expectation(description: "\(#function)")
        let request = RawUrlRequest(dataRequest: URLRequest(url: URL(string: "test.ex.temp")!))
        
        var completedCalls = 0
        
        let nextNodeContext = Context<Json>()
        let readerNodeContext = Context<Json>()
        
        nextNodeMock.stubbedProccessResult = nextNodeContext
        readerNodeMock.stubbedProccessResult = readerNodeContext
        
        // when

        sut.process(request).onCompleted { data in
            completedCalls += 1
            if completedCalls == 2 {
                expectation.fulfill()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            expectation.fulfill()
        }
        
        nextNodeContext.emit(data: Json())
        readerNodeContext.emit(data: Json())

        self.waitForExpectations(timeout: 30, handler: nil)

        // then

        XCTAssertEqual(completedCalls, 2)
        XCTAssertEqual(nextNodeMock.invokedProcessCount, 1)
        XCTAssertEqual(readerNodeMock.invokedProcessCount, 1)
    }
    
    func testAsyncProcess_whenBadInput_thenNextCalled() async throws {
        // given
        
        let exepctedNextResult = ["test0": "value0"]
        let request = RawUrlRequest(dataRequest: nil)
        
        var results: [NodeResult<Json>] = []
        
        nextNodeMock.stubbedAsyncProccessResult = .success(exepctedNextResult)

        // when

        for await result in sut.process(request, logContext: logContextMock) {
            results.append(result)
        }
        
        // then
        
        let firstResult = try XCTUnwrap(try results[0].get() as? [String: String])
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(firstResult, exepctedNextResult)
        XCTAssertFalse(readerNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_whenGoodInput_thenReaderCalled() async throws {
        // given
        
        let exepctedNextResult = ["test": "value"]
        let expectedReaderResult = ["test1": "value1"]
        let request = RawUrlRequest(dataRequest: URLRequest(url: URL(string: "test.ex.temp")!))
        
        var results: [NodeResult<Json>] = []
        
        nextNodeMock.stubbedAsyncProccessResult = .success(exepctedNextResult)
        readerNodeMock.stubbedAsyncProccessResult = .success(expectedReaderResult)
        
        // when

        for await result in sut.process(request, logContext: logContextMock) {
            results.append(result)
        }

        // then
        
        let firstResult = try XCTUnwrap(try results[0].get() as? [String: String])
        let secondResult = try XCTUnwrap(try results[1].get() as? [String: String])

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(readerNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(firstResult, expectedReaderResult)
        XCTAssertEqual(secondResult, exepctedNextResult)
    }
}
