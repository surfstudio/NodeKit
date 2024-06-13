//
//  MultipartURLRequestTrasformatorNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class MultipartURLRequestTrasformatorNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<MultipartURLRequest, Int>!
    private var logContextMock: LoggingContextMock!
    private var urlRouteProviderMock: URLRouteProviderMock!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        urlRouteProviderMock = URLRouteProviderMock()
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        urlRouteProviderMock = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_withoutURL_thenNextDidNotCall() async {
        // given
        
        let sut = MultipartURLRequestTrasformatorNode(next: nextNodeMock, method: .trace)
        let model = RoutableRequestModel<URLRouteProvider, MultipartModel<[String : Data]>>(
            metadata: [:],
            raw: MultipartModel<[String : Data]>(payloadModel: [:]),
            route: urlRouteProviderMock
        )
        
        urlRouteProviderMock.stubbedURLResult = .failure(MockError.thirdError)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_withoutURL_thenErrorReceived() async throws {
        // given
        
        let sut = MultipartURLRequestTrasformatorNode(next: nextNodeMock, method: .trace)
        let model = RoutableRequestModel<URLRouteProvider, MultipartModel<[String : Data]>>(
            metadata: [:],
            raw: MultipartModel<[String : Data]>(payloadModel: [:]),
            route: urlRouteProviderMock
        )
        
        urlRouteProviderMock.stubbedURLResult = .failure(MockError.thirdError)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        XCTAssertEqual(error, .thirdError)
    }
    
    func testAsyncProcess_withCorrentURL_thenNextCalled() async {
        // given
        
        let sut = MultipartURLRequestTrasformatorNode(next: nextNodeMock, method: .options)
        let model = RoutableRequestModel<URLRouteProvider, MultipartModel<[String : Data]>>(
            metadata: [:],
            raw: MultipartModel<[String : Data]>(payloadModel: [:]),
            route: urlRouteProviderMock
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        urlRouteProviderMock.stubbedURLResult = .success(URL(string: "www.test.com")!)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        XCTAssertEqual(urlRouteProviderMock.invokedURLCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
    }
    
    func testAsyncProcess_withSuccessResponse_thenMultipartRequestCreated() async throws {
        // given
        
        let sut = MultipartURLRequestTrasformatorNode(next: nextNodeMock, method: .options)
        let expectedResult = 15
        let expectedURL = URL(string: "www.test.com")!
        let multipartModel = MultipartModel<[String : Data]>(payloadModel: [
            "TestMultipartKey": "TestMultipartValue".data(using: .utf8)!
        ])
        let metadata = ["TestMetadataKey": "TestMetadataValue"]
        let model = RoutableRequestModel<URLRouteProvider, MultipartModel<[String : Data]>>(
            metadata: metadata,
            raw: multipartModel,
            route: urlRouteProviderMock
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        urlRouteProviderMock.stubbedURLResult = .success(expectedURL)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        
        XCTAssertEqual(input.headers , metadata)
        XCTAssertEqual(input.method, .options)
        XCTAssertEqual(input.url, expectedURL)
        XCTAssertEqual(input.data.payloadModel, multipartModel.payloadModel)
    }
    
    func testAsyncProcess_withSuccessResponse_thenSuccessReceived() async throws {
        // given
        
        let sut = MultipartURLRequestTrasformatorNode(next: nextNodeMock, method: .options)
        let expectedResult = 99
        let model = RoutableRequestModel<URLRouteProvider, MultipartModel<[String : Data]>>(
            metadata: [:],
            raw: MultipartModel<[String : Data]>(payloadModel: [:]),
            route: urlRouteProviderMock
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        urlRouteProviderMock.stubbedURLResult = .success(URL(string: "www.test.com")!)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withFailureResponse_thenFailureReceived() async throws {
        // given
        
        let sut = MultipartURLRequestTrasformatorNode(next: nextNodeMock, method: .options)
        let model = RoutableRequestModel<URLRouteProvider, MultipartModel<[String : Data]>>(
            metadata: [:],
            raw: MultipartModel<[String : Data]>(payloadModel: [:]),
            route: urlRouteProviderMock
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.secondError)
        urlRouteProviderMock.stubbedURLResult = .success(URL(string: "www.test.com")!)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        XCTAssertEqual(error, .secondError)
    }
    
    func testAsyncProcess_withCancelTask_beforeStart_thenCancellationErrorReceived() async throws {
        // given
        
        let sut = MultipartURLRequestTrasformatorNode(next: nextNodeMock, method: .options)
        let model = RoutableRequestModel<URLRouteProvider, MultipartModel<[String : Data]>>(
            metadata: [:],
            raw: MultipartModel<[String : Data]>(payloadModel: [:]),
            route: urlRouteProviderMock
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        urlRouteProviderMock.stubbedURLResult = .success(URL(string: "www.test.com")!)
        
        // when
        
        let task = Task {
            try? await Task.sleep(nanoseconds: 100 * 1000)
            return await sut.process(model, logContext: LoggingContextMock())
        }
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
    
    func testAsyncProcess_withCancelTask_afterStart_thenCancellationErrorReceived() async throws {
        // given
        
        let sut = MultipartURLRequestTrasformatorNode(next: nextNodeMock, method: .options)
        let model = RoutableRequestModel<URLRouteProvider, MultipartModel<[String : Data]>>(
            metadata: [:],
            raw: MultipartModel<[String : Data]>(payloadModel: [:]),
            route: urlRouteProviderMock
        )
        
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        urlRouteProviderMock.stubbedURLResult = .success(URL(string: "www.test.com")!)
        
        nextNodeMock.stubbedAsyncProcessRunFunction = {
            try? await Task.sleep(nanoseconds: 3 * 1000 * 1000)
        }
        
        // when
        
        let task = Task {
            await sut.process(model, logContext: LoggingContextMock())
        }
        
        try? await Task.sleep(nanoseconds: 100 * 1000)
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
}
