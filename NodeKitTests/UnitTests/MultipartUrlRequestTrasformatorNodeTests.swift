//
//  MultipartUrlRequestTrasformatorNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class MultipartUrlRequestTrasformatorNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<MultipartUrlRequest, Int>!
    private var logContextMock: LoggingContextMock!
    private var urlRouteProviderMock: UrlRouteProviderMock!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        urlRouteProviderMock = UrlRouteProviderMock()
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        urlRouteProviderMock = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_withoutUrl_thenErrorReceived() async throws {
        // given
        
        let sut = MultipartUrlRequestTrasformatorNode(next: nextNodeMock, method: .trace)
        let multipartModel = MultipartModel<[String : Data]>(payloadModel: [
            "TestMultipartKey": "TestMultipartValue".data(using: .utf8)!
        ])
        let metadata = ["TestMetadataKey": "TestMetadataValue"]
        let model = RoutableRequestModel<UrlRouteProvider, MultipartModel<[String : Data]>>(
            metadata: metadata,
            raw: multipartModel,
            route: urlRouteProviderMock
        )
        
        urlRouteProviderMock.stubbedUrlResult = .failure(MockError.thirdError)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(urlRouteProviderMock.invokedUrlCount, 1)
        XCTAssertEqual(error, .thirdError)
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_withUrl_withSuccessResponse_thenMultipartRequestCreated_andSuccessReceived() async throws {
        // given
        
        let sut = MultipartUrlRequestTrasformatorNode(next: nextNodeMock, method: .options)
        let expectedResult = 15
        let expectedUrl = URL(string: "www.test.com")!
        let multipartModel = MultipartModel<[String : Data]>(payloadModel: [
            "TestMultipartKey": "TestMultipartValue".data(using: .utf8)!
        ])
        let metadata = ["TestMetadataKey": "TestMetadataValue"]
        let model = RoutableRequestModel<UrlRouteProvider, MultipartModel<[String : Data]>>(
            metadata: metadata,
            raw: multipartModel,
            route: urlRouteProviderMock
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        urlRouteProviderMock.stubbedUrlResult = .success(expectedUrl)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0)
        let value = try XCTUnwrap(result.value)
        
        XCTAssertEqual(urlRouteProviderMock.invokedUrlCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.headers , metadata)
        XCTAssertEqual(input.method, .options)
        XCTAssertEqual(input.url, expectedUrl)
        XCTAssertEqual(input.data.payloadModel, multipartModel.payloadModel)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withUrl_withFailureResponse_thenMultipartRequestCreated_andFailureReceived() async throws {
        // given
        
        let sut = MultipartUrlRequestTrasformatorNode(next: nextNodeMock, method: .get)
        let expectedUrl = URL(string: "www.test.com")!
        let multipartModel = MultipartModel<[String : Data]>(payloadModel: [
            "TestMultipartKey1": "TestMultipartValue1".data(using: .utf8)!
        ])
        let metadata = ["TestMetadataKey2": "TestMetadataValue2"]
        let model = RoutableRequestModel<UrlRouteProvider, MultipartModel<[String : Data]>>(
            metadata: metadata,
            raw: multipartModel,
            route: urlRouteProviderMock
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        urlRouteProviderMock.stubbedUrlResult = .success(expectedUrl)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0)
        let error = try XCTUnwrap(result.error as? MockError)
        
        XCTAssertEqual(urlRouteProviderMock.invokedUrlCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(input.headers , metadata)
        XCTAssertEqual(input.method, .get)
        XCTAssertEqual(input.url, expectedUrl)
        XCTAssertEqual(input.data.payloadModel, multipartModel.payloadModel)
        XCTAssertEqual(error, .secondError)
    }
}
