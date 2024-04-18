//
//  MultipartRequestCreatorNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class MultipartRequestCreatorNodeTest: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<URLRequest, Int>!
    private var logContextMock: LoggingContextMock!
    private var multipartFormDataFactoryMock: MultipartFormDataFactoryMock!
    private var multipartFormDataMock: MultipartFormDataMock!
    
    // MARK: - Sut
    
    private var sut: MultipartRequestCreatorNode<Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        multipartFormDataFactoryMock = MultipartFormDataFactoryMock()
        multipartFormDataMock = MultipartFormDataMock()
        multipartFormDataFactoryMock.stubbedProduceResult = multipartFormDataMock
        sut = MultipartRequestCreatorNode(
            next: nextNodeMock,
            multipartFormDataFactory: multipartFormDataFactoryMock
        )
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        multipartFormDataFactoryMock = nil
        multipartFormDataMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_withMultipartFormPayloadData_thenMultipartFormDataAppendCalled() async throws {
        // given
        
        let payloadKey = "TestPayloadKey"
        let payloadValue = "TestPayloadValue".data(using: .utf8)!
        let multipartModel = MultipartModel<[String: Data]>(
            payloadModel: [
                payloadKey: payloadValue
            ]
        )
        
        let model = MultipartURLRequest(
            method: .delete,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            data: multipartModel
        )
        
        multipartFormDataMock.stubbedContentTypeResult = "TestContentType"
        multipartFormDataMock.stubbedEncodeResult = .success(Data())
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let multipartDataInput = try XCTUnwrap(multipartFormDataMock.invokedAppendDataParameters)
        
        XCTAssertEqual(multipartFormDataFactoryMock.invokedProduceCount, 1)
        XCTAssertEqual(multipartFormDataMock.invokedAppendDataCount, 1)
        XCTAssertEqual(multipartDataInput.name, payloadKey)
        XCTAssertEqual(multipartDataInput.data, payloadValue)
        XCTAssertNil(multipartDataInput.fileName)
        XCTAssertNil(multipartDataInput.mimeType)
        XCTAssertFalse(multipartFormDataMock.invokedAppendURL)
        XCTAssertFalse(multipartFormDataMock.invokedAppendCustomURL)
    }
    
    func testAsyncProcess_withMultipartFormFileURL_thenMultipartFormDataAppendCalled() async throws {
        // given
        
        let fileKey = "TestFileKey1"
        let fileURL = URL(string: "www.testfirstfile.com")!
        let multipartModel = MultipartModel<[String: Data]>(
            payloadModel: [:],
            files: [fileKey: .url(url: fileURL)]
        )
        
        let model = MultipartURLRequest(
            method: .delete,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            data: multipartModel
        )
        
        multipartFormDataMock.stubbedContentTypeResult = "TestContentType"
        multipartFormDataMock.stubbedEncodeResult = .success(Data())
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let multipartDataInput = try XCTUnwrap(multipartFormDataMock.invokedAppendURLParameters)
        
        XCTAssertEqual(multipartFormDataFactoryMock.invokedProduceCount, 1)
        XCTAssertEqual(multipartFormDataMock.invokedAppendURLCount, 1)
        XCTAssertEqual(multipartDataInput.name, fileKey)
        XCTAssertEqual(multipartDataInput.fileURL, fileURL)
        XCTAssertFalse(multipartFormDataMock.invokedAppendData)
        XCTAssertFalse(multipartFormDataMock.invokedAppendCustomURL)
    }
    
    func testAsyncProcess_withMultipartFormFileData_thenMultipartFormDataAppendCalled() async throws {
        // given
        
        let fileKey = "TestFileKey2"
        let fileData = "TestSecondFileData".data(using: .utf8)!
        let fileName = "TestSecondFile.name"
        let fileMimeType = "TestSecondFileMimeType"
        let multipartModel = MultipartModel<[String: Data]>(
            payloadModel: [:],
            files: [fileKey: .data(data: fileData, filename: fileName, mimetype: fileMimeType)]
        )
        
        let model = MultipartURLRequest(
            method: .delete,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            data: multipartModel
        )
        
        multipartFormDataMock.stubbedContentTypeResult = "TestContentType"
        multipartFormDataMock.stubbedEncodeResult = .success(Data())
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let multipartDataInput = try XCTUnwrap(multipartFormDataMock.invokedAppendDataParameters)
        
        XCTAssertEqual(multipartFormDataFactoryMock.invokedProduceCount, 1)
        XCTAssertEqual(multipartFormDataMock.invokedAppendDataCount, 1)
        XCTAssertEqual(multipartDataInput.name, fileKey)
        XCTAssertEqual(multipartDataInput.data, fileData)
        XCTAssertEqual(multipartDataInput.fileName, fileName)
        XCTAssertEqual(multipartDataInput.mimeType, fileMimeType)
        XCTAssertFalse(multipartFormDataMock.invokedAppendURL)
        XCTAssertFalse(multipartFormDataMock.invokedAppendCustomURL)
    }
    
    func testAsyncProcess_withMultipartFormFileCustomURL_thenMultipartFormDataAppendCalled() async throws {
        // given
        
        let fileKey = "TestFileKey3"
        let fileURL = URL(string: "www.testthirdfile.com")!
        let fileName = "TestThirdFile.name"
        let fileMimeType = "TestThirdFileMimeType"
        let multipartModel = MultipartModel<[String: Data]>(
            payloadModel: [:],
            files: [fileKey: .customWithURL(url: fileURL, filename: fileName, mimetype: fileMimeType)]
        )
        
        let model = MultipartURLRequest(
            method: .delete,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            data: multipartModel
        )
        
        multipartFormDataMock.stubbedContentTypeResult = "TestContentType"
        multipartFormDataMock.stubbedEncodeResult = .success(Data())
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let multipartDataInput = try XCTUnwrap(multipartFormDataMock.invokedAppendCustomURLParameters)
        
        XCTAssertEqual(multipartFormDataFactoryMock.invokedProduceCount, 1)
        XCTAssertEqual(multipartFormDataMock.invokedAppendCustomURLCount, 1)
        XCTAssertEqual(multipartDataInput.name, fileKey)
        XCTAssertEqual(multipartDataInput.fileURL, fileURL)
        XCTAssertEqual(multipartDataInput.fileName, fileName)
        XCTAssertEqual(multipartDataInput.mimeType, fileMimeType)
        XCTAssertFalse(multipartFormDataMock.invokedAppendURL)
        XCTAssertFalse(multipartFormDataMock.invokedAppendData)
    }
    
    func testAsyncProcess_withEncodingError_thenNextDidNotCall() async throws {
        // given

        let model = MultipartURLRequest(
            method: .delete,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            data: MultipartModel<[String: Data]>(payloadModel: [:])
        )
        
        multipartFormDataMock.stubbedContentTypeResult = "TestContentType"
        multipartFormDataMock.stubbedEncodeResult = .failure(MockError.secondError)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        XCTAssertEqual(multipartFormDataMock.invokedEncodeCount, 1)
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
    }
    
    func testAsyncProcess_withEncodingError_thenErrorReceived() async throws {
        // given

        let model = MultipartURLRequest(
            method: .delete,
            url: URL(string: "www.testprocess.com")!,
            headers: ["TestHeaderKey": "TestHeaderValue"],
            data: MultipartModel<[String: Data]>(payloadModel: [:])
        )
        
        multipartFormDataMock.stubbedContentTypeResult = "TestContentType"
        multipartFormDataMock.stubbedEncodeResult = .failure(MockError.secondError)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        XCTAssertEqual(error, .secondError)
    }
    
    func testAsyncProcess_withEncodingSuccess_thenNextCalled() async throws {
        // given

        let expectedURL = URL(string: "www.testprocess.com")!
        let stubbedContentType = "TestContentType"
        let headers = ["TestHeaderKey": "TestHeaderValue"]
        let model = MultipartURLRequest(
            method: .delete,
            url: expectedURL,
            headers: headers,
            data: MultipartModel<[String: Data]>(payloadModel: [:])
        )
        let expectedHeaders = [
            "TestHeaderKey": "TestHeaderValue",
            "Content-Type": stubbedContentType
        ]
        let multipartData = "TestData".data(using: .utf8)!
        
        multipartFormDataMock.stubbedContentTypeResult = stubbedContentType
        multipartFormDataMock.stubbedEncodeResult = .success(multipartData)
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
        // when
        
        _ = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let nextNodeInput = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let httpHeaders = try XCTUnwrap(nextNodeInput.allHTTPHeaderFields)
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeInput.url, expectedURL)
        XCTAssertEqual(nextNodeInput.httpMethod, NodeKit.Method.delete.rawValue)
        XCTAssertEqual(nextNodeInput.httpBody, multipartData)
        XCTAssertEqual(httpHeaders, expectedHeaders)
    }
    
    func testAsyncProcess_withSuccess_thenSuccessReceived() async throws {
        // given

        let model = MultipartURLRequest(
            method: .get,
            url: URL(string: "www.testprocess.com")!,
            headers: [:],
            data: MultipartModel<[String: Data]>(payloadModel: [:])
        )
        let expectedResult = 78
        
        multipartFormDataMock.stubbedContentTypeResult = ""
        multipartFormDataMock.stubbedEncodeResult = .success(Data())
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let value = try XCTUnwrap(result.value)
        XCTAssertEqual(value, expectedResult)
    }
    
    func testAsyncProcess_withError_thenErrorReceived() async throws {
        // given

        let model = MultipartURLRequest(
            method: .get,
            url: URL(string: "www.testprocess.com")!,
            headers: [:],
            data: MultipartModel<[String: Data]>(payloadModel: [:])
        )
        
        multipartFormDataMock.stubbedContentTypeResult = ""
        multipartFormDataMock.stubbedEncodeResult = .success(Data())
        nextNodeMock.stubbedAsyncProccessResult = .failure(MockError.thirdError)
        
        // when
        
        let result = await sut.process(model, logContext: logContextMock)
        
        // then
        
        let error = try XCTUnwrap(result.error as? MockError)
        XCTAssertEqual(error, .thirdError)
    }
    
    func testAsyncProcess_withCancelTask_beforeStart_thenCancellationErrorReceived() async throws {
        // given
        
        let model = MultipartUrlRequest(
            method: .get,
            url: URL(string: "www.testprocess.com")!,
            headers: [:],
            data: MultipartModel<[String: Data]>(payloadModel: [:])
        )
        
        multipartFormDataMock.stubbedContentTypeResult = ""
        multipartFormDataMock.stubbedEncodeResult = .success(Data())
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
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
        
        let model = MultipartUrlRequest(
            method: .get,
            url: URL(string: "www.testprocess.com")!,
            headers: [:],
            data: MultipartModel<[String: Data]>(payloadModel: [:])
        )
        
        multipartFormDataMock.stubbedContentTypeResult = ""
        multipartFormDataMock.stubbedEncodeResult = .success(Data())
        nextNodeMock.stubbedAsyncProccessResult = .success(1)
        
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
