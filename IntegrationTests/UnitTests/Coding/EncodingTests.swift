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

    class StubNext: RequestProcessingLayerNode {

        var request: RawUrlRequest! = nil

        @discardableResult
        public override func process(_ data: RawUrlRequest) -> Observer<Json> {
            self.request = data
            return .emit(data: Json())
        }
    }

    public func testFormUrlConvertinWork() {
        // Arrange

        let nextNode = StubNext()
        let node = RequestCreatorNode(next: nextNode)
        let url = "http://test.com/usr"

        // Act

        let params = TransportUrlParameters(method: .post,
                                            url: URL(string: url)!,
                                            headers: [:],
                                            parametersEncoding: .formUrl)
        let trasportReq = TransportUrlRequest(with: params, raw: ["id": "123455"])

        _ = node.process(trasportReq)

        // Assert

        XCTAssertEqual(nextNode.request.dataRequest.convertible.urlRequest!.url!.absoluteString, url)
    }

    public func testUrlQueryConvertionWork() {
        // Arrange

        let nextNode = StubNext()
        let node = RequestCreatorNode(next: nextNode)
        let url = "http://test.com/usr"

        // Act

        let params = TransportUrlParameters(method: .post,
                                            url: URL(string: url)!,
                                            headers: [:],
                                            parametersEncoding: .urlQuery)
        let trasportReq = TransportUrlRequest(with: params, raw: ["id": "12345"])

        _ = node.process(trasportReq)

        // Assert

        XCTAssertEqual(nextNode.request.dataRequest.convertible.urlRequest!.url!.absoluteString, "\(url)?id=12345")
    }

    func testJsonConvertionWork() {
        // Arrange

        let nextNode = StubNext()
        let node = RequestCreatorNode(next: nextNode)
        let url = "http://test.com/usr"

        // Act

        let params = TransportUrlParameters(method: .post,
                                            url: URL(string: url)!,
                                            headers: [:], parametersEncoding: .json)
        let trasportReq = TransportUrlRequest(with: params, raw: ["id": "12345"])

        _ = node.process(trasportReq)

        // Assert

        XCTAssertEqual(nextNode.request.dataRequest.convertible.urlRequest!.url!.absoluteString, url)
    }
}
