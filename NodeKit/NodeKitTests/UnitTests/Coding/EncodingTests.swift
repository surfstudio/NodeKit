//
//  FormURLEncodingTests.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 31/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Foundation
import XCTest

final class EncodingTests: XCTestCase {

    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<URLRequest, Json>!
    private var requestCreatorNode: RequestCreatorNode<Json>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: URLJsonRequestEncodingNode<Json>!
    
    // MARK: - Lifecycle
    
    public override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        requestCreatorNode = RequestCreatorNode(next: nextNodeMock)
        sut = URLJsonRequestEncodingNode(next: requestCreatorNode)
    }
    
    public override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        requestCreatorNode = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_thenFormURLConvertinWork() async throws {
        // given
        
        let url = "http://test.com/usr"
        let headersArray: [String: String] = [
            "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
        ]
        let dataRaw: Json = ["id": "123455"]
        let urlParameters = TransportURLParameters(method: .post, url: URL(string: url)!)
        let encodingModel = RequestEncodingModel(
            urlParameters: urlParameters,
            raw: dataRaw,
            encoding: .formURL
        )
        let expectedResult = ["Test": "Value"]
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)

        // when

        let result = await sut.process(encodingModel, logContext: logContextMock)

        // then
        
        let unwrappedResult = try XCTUnwrap(try result.get() as? [String: String])
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessParameters?.data.url!.absoluteString, url)
        XCTAssertEqual(
            nextNodeMock.invokedAsyncProcessParameters?.data.headers.dictionary,
            headersArray
        )
        XCTAssertEqual(unwrappedResult, expectedResult)
    }
    
    public func testAsyncProcess_thenURLQueryConvertionWork() async throws {
        // given

        let url = "http://test.com/usr"
        let dataRaw: Json = ["id": "12345"]
        let urlParameters = TransportURLParameters(method: .post, url: URL(string: url)!)
        let encodingModel = RequestEncodingModel(
            urlParameters: urlParameters,
            raw: dataRaw,
            encoding: .urlQuery
        )
        
        let expectedResult = ["Test1": "Value1"]
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        
        // when

        let result = await sut.process(encodingModel, logContext: logContextMock)

        // then
        
        let unwrappedResult = try XCTUnwrap(try result.get() as? [String: String])
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(
            nextNodeMock?.invokedAsyncProcessParameters?.data.url!.absoluteString,
            "\(url)?id=12345"
        )
        XCTAssertEqual(unwrappedResult, expectedResult)
    }

    func testAsyncProcess_thenJsonConvertionWork() async throws {
        // given

        let url = "http://test.com/usr"
        let headersArray: [String: String] = ["Content-Type": "application/json"]
        let dataRaw: Json = ["id": "12345"]
        let urlParameters = TransportURLParameters(method: .post, url: URL(string: url)!)
        let encodingModel = RequestEncodingModel(
            urlParameters: urlParameters,
            raw: dataRaw,
            encoding: .json
        )
        
        let expectedResult = ["Test2": "Value2"]
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)

        // when
        
        let result = await sut.process(encodingModel, logContext: logContextMock)

        // then
        
        let unwrappedResult = try XCTUnwrap(try result.get() as? [String: String])
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessParameters?.data.url!.absoluteString, url)
        XCTAssertEqual(
            nextNodeMock.invokedAsyncProcessParameters?.data.headers.dictionary,
            headersArray
        )
        XCTAssertEqual(unwrappedResult, expectedResult)
    }
    
    func testAsyncProcess_withGetParameter_thenJsonConvertionWork() async throws {
        // given

        let url = "http://test.com/usr"
        let dataRaw: Json = ["id": "12345"]
        let urlParameters = TransportURLParameters(method: .get, url: URL(string: url)!)
        let encodingModel = RequestEncodingModel(
            urlParameters: urlParameters,
            raw: dataRaw,
            encoding: .json
        )
        
        let expectedResult = ["Test2": "Value2"]
        let expectedURL = url + "?id=12345"
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)

        // when
        
        let result = await sut.process(encodingModel, logContext: logContextMock)

        // then
        
        let unwrappedResult = try XCTUnwrap(try result.get() as? [String: String])
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessParameters?.data.url!.absoluteString, expectedURL)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessParameters?.data.headers.dictionary.isEmpty, true)
        XCTAssertEqual(unwrappedResult, expectedResult)
    }
    
    func testAsyncProcess_whenEncodingParametersMissed_thenErrorReceived() async throws {
        // given

        let url = "http://test.com/usr"
        let dataRaw: Json = ["id": "12345"]
        let urlParameters = TransportURLParameters(method: .post, url: URL(string: url)!)
        let encodingModel = RequestEncodingModel(
            urlParameters: urlParameters,
            raw: dataRaw,
            encoding: nil
        )
        
        let expectedResult = ["Test2": "Value2"]
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedResult)

        // when
        
        let result = await sut.process(encodingModel, logContext: logContextMock)

        // then
        
        let unwrappedResult = try XCTUnwrap(result.error as? RequestEncodingNodeError)
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
        XCTAssertEqual(unwrappedResult, .missedJsonEncodingType)
    }
}
