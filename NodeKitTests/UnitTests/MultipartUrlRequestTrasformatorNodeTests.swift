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
    
    func testAsyncProcess_withoutUrl_thenNextDidNotCall() async {
        // given
        
        let sut = MultipartUrlRequestTrasformatorNode(next: nextNodeMock, method: .trace)
        let model = RoutableRequestModel<UrlRouteProvider, MultipartModel<[String : Data]>>(
            metadata: [:],
            raw: MultipartModel<[String : Data]>(payloadModel: [:]),
            route: urlRouteProviderMock
        )
        
        urlRouteProviderMock.stubbedUrlResult = .failure(MockError.thirdError)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_withoutUrl_thenErrorReceived() async throws {
        // given
        
        let sut = MultipartUrlRequestTrasformatorNode(next: nextNodeMock, method: .trace)
        let model = RoutableRequestModel<UrlRouteProvider, MultipartModel<[String : Data]>>(
            metadata: [:],
            raw: MultipartModel<[String : Data]>(payloadModel: [:]),
            route: urlRouteProviderMock
        )
        
        urlRouteProviderMock.stubbedUrlResult = .failure(MockError.thirdError)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        XCTAssertEqual(error, .thirdError)
    }
    
    func testAsyncProcess_withCorrentURL_thenNextCalled() async {
        // given
        
        let sut = MultipartUrlRequestTrasformatorNode(next: nextNodeMock, method: .options)
        let model = RoutableRequestModel<UrlRouteProvider, MultipartModel<[String : Data]>>(
            metadata: [:],
            raw: MultipartModel<[String : Data]>(payloadModel: [:]),
            route: urlRouteProviderMock
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        urlRouteProviderMock.stubbedUrlResult = .success(URL(string: "www.test.com")!)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        XCTAssertEqual(urlRouteProviderMock.invokedUrlCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
    }
    
    func testAsyncProcess_withSuccessResponse_thenMultipartRequestCreated() async throws {
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
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(input.headers , metadata)
        XCTAssertEqual(input.method, .options)
        XCTAssertEqual(input.url, expectedUrl)
        XCTAssertEqual(input.data.payloadModel, multipartModel.payloadModel)
    }
    
    func testAsyncProcess_withSuccessResponse_thenSuccessReceived() async throws {
        // given
        
        let sut = MultipartUrlRequestTrasformatorNode(next: nextNodeMock, method: .options)
        let expectedResult = 99
        let model = RoutableRequestModel<UrlRouteProvider, MultipartModel<[String : Data]>>(
            metadata: [:],
            raw: MultipartModel<[String : Data]>(payloadModel: [:]),
            route: urlRouteProviderMock
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        urlRouteProviderMock.stubbedUrlResult = .success(URL(string: "www.test.com")!)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withFailureResponse_thenFailureReceived() async throws {
        // given
        
        let sut = MultipartUrlRequestTrasformatorNode(next: nextNodeMock, method: .options)
        let model = RoutableRequestModel<UrlRouteProvider, MultipartModel<[String : Data]>>(
            metadata: [:],
            raw: MultipartModel<[String : Data]>(payloadModel: [:]),
            route: urlRouteProviderMock
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        urlRouteProviderMock.stubbedUrlResult = .success(URL(string: "www.test.com")!)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        XCTAssertEqual(error, .secondError)
    }
}
