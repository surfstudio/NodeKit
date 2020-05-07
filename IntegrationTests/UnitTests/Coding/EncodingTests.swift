//
//  FormUrlEncodingTests.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 31/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

public class EncodingTests: XCTestCase {

    class StubNext: RequestProcessingLayerNode {

        var request: URLRequest! = nil

        @discardableResult
        public override func process(_ data: URLRequest) -> Observer<Json> {
            self.request = data
            return .emit(data: Json())
        }
    }

    public func testFormUrlConvertinWork() {
        // Arrange

        let nextNode = StubNext()
        let node = RequestCreatorNode(next: nextNode)
        let requestEncodingNode = UrlRequestEncodingNode<Json, Json>(next: node)
        let url = "http://test.com/usr"

        // Act

        let dataRaw: Json = ["id": "123455"]
        let urlParameters = TransportUrlParameters(method: .post, url: URL(string: url)!)
        let encodingModel = RequestEncodingModel(urlParameters: urlParameters, raw: dataRaw, encoding: .formUrl)

        _ = requestEncodingNode.process(encodingModel)

        // Assert

        XCTAssertEqual(nextNode.request.url!.absoluteString, url)
    }

    public func testUrlQueryConvertionWork() {
        // Arrange

        let nextNode = StubNext()
        let node = RequestCreatorNode(next: nextNode)
        let requestEncodingNode = UrlRequestEncodingNode<Json, Json>(next: node)
        let url = "http://test.com/usr"

        // Act

        let dataRaw: Json = ["id": "12345"]
        let urlParameters = TransportUrlParameters(method: .post, url: URL(string: url)!)
        let encodingModel = RequestEncodingModel(urlParameters: urlParameters, raw: dataRaw, encoding: .urlQuery)

        _ = requestEncodingNode.process(encodingModel)

        // Assert

        XCTAssertEqual(nextNode.request.url!.absoluteString, "\(url)?id=12345")
    }

    func testJsonConvertionWork() {
        // Arrange

        let nextNode = StubNext()
        let node = RequestCreatorNode(next: nextNode)
        let requestEncodingNode = UrlRequestEncodingNode<Json, Json>(next: node)
        let url = "http://test.com/usr"

        // Act

        let dataRaw: Json = ["id": "12345"]
        let urlParameters = TransportUrlParameters(method: .post, url: URL(string: url)!)
        let encodingModel = RequestEncodingModel(urlParameters: urlParameters, raw: dataRaw, encoding: .json)

        _ = requestEncodingNode.process(encodingModel)

        // Assert

        XCTAssertEqual(nextNode.request.url!.absoluteString, url)
    }

}
