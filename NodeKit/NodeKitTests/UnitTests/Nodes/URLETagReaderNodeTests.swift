//
//  URLETagReaderNodeTests.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Foundation
import XCTest

final class URLETagReaderNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<TransportURLRequest, Json>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: URLETagReaderNode!
    
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
    
    func testAsyncProcess_whenSuccess() async throws {
        
        // given
        
        buildSut()
        
        let tag = "\(NSObject().hash)"
        let url = URL(string: "http://URLETagReaderNodeTests/testReadSuccess")!
        let params = TransportURLParameters(method: .get, url: url)
        let request = TransportURLRequest(with:params , raw: Data())
        
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
        
        let nextNodeParameter = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)

        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeParameter.method, request.method)
        XCTAssertEqual(nextNodeParameter.url, request.url)
        XCTAssertEqual(nextNodeParameter.raw, request.raw)
        XCTAssertEqual(nextNodeParameter.headers, expectedHeader)
    }
    
    func testAsyncProcess_whenTagNotExist() async throws {
        // given
        
        buildSut()

        let url = URL(string: "http://URLETagReaderNodeTests/testNotReadIfTagNotExist")!
        let params = TransportURLParameters(method: .get, url: url)
        let request = TransportURLRequest(with:params , raw: Data())
        
        nextNodeMock.stubbedAsyncProccessResult = .success(Json())

        // when

        _ = await sut.process(request, logContext: logContextMock)

        // then
        
        let nextProcessInvokedParameter = try XCTUnwrap(
            nextNodeMock.invokedAsyncProcessParameters?.data
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

        let url = URL(string: "http://URLETagReaderNodeTests/testReadSuccessWithCustomKey")!
        let params = TransportURLParameters(method: .get, url: url)
        let request = TransportURLRequest(with:params , raw: Data())
        
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
            nextNodeMock.invokedAsyncProcessParameters?.data
        )

        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeParameter.method, request.method)
        XCTAssertEqual(nextNodeParameter.url, request.url)
        XCTAssertEqual(nextNodeParameter.raw, request.raw)
        XCTAssertEqual(nextNodeParameter.headers, expectedHeader)
    }
    
    private func buildSut(with tag: String? = nil) {
        guard let tag = tag else {
            sut = URLETagReaderNode(next: nextNodeMock)
            return
        }
        sut = URLETagReaderNode(next: nextNodeMock, etagHeaderKey: tag)
    }
}
