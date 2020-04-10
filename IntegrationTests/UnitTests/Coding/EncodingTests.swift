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
import Alamofire

@testable
import NodeKit

public class EncodingTests: XCTestCase {

    enum EncodingRoutes: UrlRouteProvider {

        enum Exception: Error {
            case badUrl
        }

        case usr

        func url() throws -> URL {
            guard let url = self.tryToGetUrl() else {
                throw Exception.badUrl
            }

            return url
        }

        func tryToGetUrl() -> URL? {
            switch self {
            case .usr:
                return URL(string: "http://test.com/usr")
            }
        }

    }

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
        let requestTransformNode = UrlRequestTrasformatorNode<Json, Json>(next: node, method: .post)
        let url = "http://test.com/usr"

        // Act

        let dataRaw = ["id": "123455"]
        let encodableModel = EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding>(metadata: [:], raw: dataRaw, route: EncodingRoutes.usr, encoding: .formUrl)

        _ = requestTransformNode.process(encodableModel)

        // Assert

        XCTAssertEqual(nextNode.request.url!.absoluteString, url)
    }

    public func testUrlQueryConvertionWork() {
        // Arrange

        let nextNode = StubNext()
        let node = RequestCreatorNode(next: nextNode)
        let requestTransformNode = UrlRequestTrasformatorNode<Json, Json>(next: node, method: .post)
        let url = "http://test.com/usr"

        // Act

        let dataRaw = ["id": "12345"]
        let encodableModel = EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding>(metadata: [:], raw: dataRaw, route: EncodingRoutes.usr, encoding: .urlQuery)

        _ = requestTransformNode.process(encodableModel)

        // Assert

        XCTAssertEqual(nextNode.request.url!.absoluteString, "\(url)?id=12345")
    }

    func testJsonConvertionWork() {
        // Arrange

        let nextNode = StubNext()
        let node = RequestCreatorNode(next: nextNode)
        let requestTransformNode = UrlRequestTrasformatorNode<Json, Json>(next: node, method: .post)
        let url = "http://test.com/usr"

        // Act

        let dataRaw = ["id": "12345"]
        let encodableModel = EncodableRequestModel<UrlRouteProvider, Json, ParametersEncoding>(metadata: [:], raw: dataRaw, route: EncodingRoutes.usr, encoding: .json)

        _ = requestTransformNode.process(encodableModel)

        // Assert

        XCTAssertEqual(nextNode.request.url!.absoluteString, url)
    }

}
