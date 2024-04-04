//
//  UrlETagReaderNodeTests.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

final class UrlETagReaderNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<TransportUrlRequest, Json>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: UrlETagReaderNode!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testProcess_whenSuccess() throws {
        
        // given
        
        buildSut()
        
        let tag = "\(NSObject().hash)"
        let url = URL(string: "http://UrlETagReaderNodeTests/testReadSuccess")!
        let params = TransportUrlParameters(method: .get, url: url)
        let request = TransportUrlRequest(with:params , raw: Data())
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: Json())
        
        var expectedHeader = request.headers
        expectedHeader[ETagConstants.eTagRequestHeaderKey] = tag

        let expectation = self.expectation(description: "\(#function)")

        defer {
            UserDefaults.etagStorage?.removeObject(forKey: url.absoluteString)
        }

        // when

        UserDefaults.etagStorage?.set(tag, forKey: url.absoluteString)

        var callCount = 0

        sut.processLegacy(request).onCompleted { _ in
            callCount += 1
            expectation.fulfill()
        }.onError { _ in
            callCount += 1
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1, handler: nil)

        // then
        
        let nextNodeParameter = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter)

        XCTAssertEqual(nextNodeMock.invokedProcessLegacyCount, 1)
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(nextNodeParameter.method, request.method)
        XCTAssertEqual(nextNodeParameter.url, request.url)
        XCTAssertEqual(nextNodeParameter.raw, request.raw)
        XCTAssertEqual(nextNodeParameter.headers, expectedHeader)
    }
    
    func testProcess_whenTagNotExist() throws {
        // given
        
        buildSut()

        let url = URL(string: "http://UrlETagReaderNodeTests/testNotReadIfTagNotExist")!
        let params = TransportUrlParameters(method: .get, url: url)
        let request = TransportUrlRequest(with:params , raw: Data())
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: Json())

        let expectation = self.expectation(description: "\(#function)")

        // when

        UserDefaults.etagStorage?.removeObject(forKey: url.absoluteString)

        var callCount = 0

        sut.processLegacy(request).onCompleted { _ in
            callCount += 1
            expectation.fulfill()
            }.onError { _ in
                callCount += 1
                expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1, handler: nil)

        // then
        
        let nextProcessInvokedParameter = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter)

        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(nextNodeMock.invokedProcessLegacyCount, 1)
        XCTAssertEqual(request.headers, nextProcessInvokedParameter.headers)
        XCTAssertEqual(request.url, nextProcessInvokedParameter.url)
        XCTAssertEqual(request.method, nextProcessInvokedParameter.method)
        XCTAssertEqual(request.raw, nextProcessInvokedParameter.raw)
    }
    
    func testProcess_whithCustomTag() throws {
        // given

        let key = "My-Custom-ETag-Key"
        let tag = "\(NSObject().hash)"
        
        buildSut(with: key)

        let url = URL(string: "http://UrlETagReaderNodeTests/testReadSuccessWithCustomKey")!
        let params = TransportUrlParameters(method: .get, url: url)
        let request = TransportUrlRequest(with:params , raw: Data())
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: Json())
        
        var expectedHeader = request.headers
        expectedHeader[key] = tag

        let expectation = self.expectation(description: "\(#function)")

        defer {
            UserDefaults.etagStorage?.removeObject(forKey: url.absoluteString)
        }

        // when

        UserDefaults.etagStorage?.set(tag, forKey: url.absoluteString)

        var callCount = 0

        sut.processLegacy(request).onCompleted { _ in
            callCount += 1
            expectation.fulfill()
            }.onError { _ in
                callCount += 1
                expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1, handler: nil)

        // then

        let nextNodeParameter = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter)

        XCTAssertEqual(nextNodeMock.invokedProcessLegacyCount, 1)
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(nextNodeParameter.method, request.method)
        XCTAssertEqual(nextNodeParameter.url, request.url)
        XCTAssertEqual(nextNodeParameter.raw, request.raw)
        XCTAssertEqual(nextNodeParameter.headers, expectedHeader)
    }
    
    func testAsyncProcess_whenSuccess() async throws {
        
        // given
        
        buildSut()
        
        let tag = "\(NSObject().hash)"
        let url = URL(string: "http://UrlETagReaderNodeTests/testReadSuccess")!
        let params = TransportUrlParameters(method: .get, url: url)
        let request = TransportUrlRequest(with:params , raw: Data())
        
        nextNodeMock.stubbedAsyncProccessResult = .success(Json())
        
        var expectedHeader = request.headers
        expectedHeader[ETagConstants.eTagRequestHeaderKey] = tag

        defer {
            UserDefaults.etagStorage?.removeObject(forKey: url.absoluteString)
        }

        // when

        UserDefaults.etagStorage?.set(tag, forKey: url.absoluteString)

        _ = await sut.process(request, logContext: logContextMock)

        // then
        
        let nextNodeParameter = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0)

        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeParameter.method, request.method)
        XCTAssertEqual(nextNodeParameter.url, request.url)
        XCTAssertEqual(nextNodeParameter.raw, request.raw)
        XCTAssertEqual(nextNodeParameter.headers, expectedHeader)
    }
    
    func testAsyncProcess_whenTagNotExist() async throws {
        // given
        
        buildSut()

        let url = URL(string: "http://UrlETagReaderNodeTests/testNotReadIfTagNotExist")!
        let params = TransportUrlParameters(method: .get, url: url)
        let request = TransportUrlRequest(with:params , raw: Data())
        
        nextNodeMock.stubbedAsyncProccessResult = .success(Json())

        // when

        _ = await sut.process(request, logContext: logContextMock)

        // then
        
        let nextProcessInvokedParameter = try XCTUnwrap(
            nextNodeMock.invokedAsyncProcessParameters?.0
        )

        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(request.headers, nextProcessInvokedParameter.headers)
        XCTAssertEqual(request.url, nextProcessInvokedParameter.url)
        XCTAssertEqual(request.method, nextProcessInvokedParameter.method)
        XCTAssertEqual(request.raw, nextProcessInvokedParameter.raw)
    }
    
    func testAsyncProcess_whithCustomTag() async throws {
        // given

        let key = "My-Custom-ETag-Key"
        let tag = "\(NSObject().hash)"
        
        buildSut(with: key)

        let url = URL(string: "http://UrlETagReaderNodeTests/testReadSuccessWithCustomKey")!
        let params = TransportUrlParameters(method: .get, url: url)
        let request = TransportUrlRequest(with:params , raw: Data())
        
        nextNodeMock.stubbedAsyncProccessResult = .success(Json())
        
        var expectedHeader = request.headers
        expectedHeader[key] = tag

        defer {
            UserDefaults.etagStorage?.removeObject(forKey: url.absoluteString)
        }

        // when

        UserDefaults.etagStorage?.set(tag, forKey: url.absoluteString)

        _ = await sut.process(request, logContext: logContextMock)

        // then

        let nextNodeParameter = try XCTUnwrap(
            nextNodeMock.invokedAsyncProcessParameters?.0
        )

        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeParameter.method, request.method)
        XCTAssertEqual(nextNodeParameter.url, request.url)
        XCTAssertEqual(nextNodeParameter.raw, request.raw)
        XCTAssertEqual(nextNodeParameter.headers, expectedHeader)
    }
    
    private func buildSut(with tag: String? = nil) {
        guard let tag = tag else {
            sut = UrlETagReaderNode(next: nextNodeMock)
            return
        }
        sut = UrlETagReaderNode(next: nextNodeMock, etagHeaderKey: tag)
    }
}
