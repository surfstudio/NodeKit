//
//  TechnicaErrorMapperNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 04.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class TechnicaErrorMapperNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<URLRequest, Json>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: TechnicaErrorMapperNode!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = TechnicaErrorMapperNode(next: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_whenNextNodeSent1020Code_thenDataNotAllowedErrorReceived() async throws {
        // given
        
        let request = URLRequest(url: URL(string: "www.testrequest.com")!)
        nextNodeMock.stubbedAsyncProccessResult = .failure(NSError(domain: "Test domain", code: -1020))
        
        // when
        
        let result = await sut.process(request, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? BaseTechnicalError)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessParameters?.data, request)
        XCTAssertEqual(error, .dataNotAllowed)
    }
    
    func testAsyncProcess_whenNextNodeSent1009Code_thenNoInternetConnectionErrorReceived() async throws {
        // given
        
        let request = URLRequest(url: URL(string: "www.testrequest.com")!)
        nextNodeMock.stubbedAsyncProccessResult = .failure(NSError(domain: "Test domain", code: -1009))
        
        // when
        
        let result = await sut.process(request, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? BaseTechnicalError)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessParameters?.data, request)
        XCTAssertEqual(error, .noInternetConnection)
    }
    
    func testAsyncProcess_whenNextNodeSent1001Code_thenTimeoutErrorReceived() async throws {
        // given
        
        let request = URLRequest(url: URL(string: "www.testrequest.com")!)
        nextNodeMock.stubbedAsyncProccessResult = .failure(NSError(domain: "Test domain", code: -1001))
        
        // when
        
        let result = await sut.process(request, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? BaseTechnicalError)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessParameters?.data, request)
        XCTAssertEqual(error, .timeout)
    }
    
    func testAsyncProcess_whenNextNodeSent1004Code_thenCantConnectToHostErrorReceived() async throws {
        // given
        
        let request = URLRequest(url: URL(string: "www.testrequest.com")!)
        nextNodeMock.stubbedAsyncProccessResult = .failure(NSError(domain: "Test domain", code: -1004))
        
        // when
        
        let result = await sut.process(request, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? BaseTechnicalError)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessParameters?.data, request)
        XCTAssertEqual(error, .cantConnectToHost)
    }
    
    func testAsyncProcess_whenNextNodeSentCustomError_thenCustomErrorReceived() async throws {
        // given
        
        let request = URLRequest(url: URL(string: "www.testrequest.com")!)
        let expectedError = NSError(domain: "Test domain", code: 111111)
        nextNodeMock.stubbedAsyncProccessResult = .failure(expectedError)
        
        // when
        
        let result = await sut.process(request, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? NSError)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessParameters?.data, request)
        XCTAssertEqual(error, expectedError)
    }
    
    func testAsyncProcess_whenNextNodeSentSuccess_thenSuccessReceived() async throws {
        // given
        
        let request = URLRequest(url: URL(string: "www.testrequest.com")!)
        let expectedResult = ["TestKey": "TestValue"]
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(request, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value as? [String: String])
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessParameters?.data, request)
        XCTAssertEqual(value, expectedResult)
    }
}
