//
//  CacheReaderNodeTests.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 01/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

public class CacheReaderNodeTests: XCTestCase {
    public func testThatReadSuccess() {

        // Arrange

        let url = URL(string: "http://example.test")!
        let request = URLRequest(url: url)
        let model = UrlNetworkRequest(urlRequest: request)
        let testNode = UrlCacheReaderNode(needsToThrowError: true)

        URLCache.shared.removeAllCachedResponses()

        let responseKey = "name"
        let responseValue = "test"
        let response = [responseKey: responseValue]
        let responseData = try! JSONSerialization.data(withJSONObject: response,
                                                       options: .sortedKeys)

        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: nil)!

        let cachedRequest = CachedURLResponse(response: urlResponse, data: responseData)
        URLCache.shared.storeCachedResponse(cachedRequest, for: request)


        // Act

        var json: Json?

        testNode.process(model).onCompleted { data in
            json = data
        }.onError { error in
            XCTFail("\(error)")
        }

        // Assert

        guard let guardedData = json else { return }


        XCTAssertTrue(guardedData.keys.contains(responseKey))
        XCTAssertTrue((guardedData[responseKey] as? String) == responseValue)
    }

    public func testThatDontReadNotOwnRequest() {

        // Arrange

        let url = URL(string: "http://example.test/usr?id=123")!
        let request = URLRequest(url: url)
        let testNode = UrlCacheReaderNode(needsToThrowError: true)

        URLCache.shared.removeAllCachedResponses()

        let responseData = try! JSONSerialization.data(withJSONObject: ["name": "test"],
                                                       options: .sortedKeys)

        let urlResponse = HTTPURLResponse(url: url,
                                          statusCode: 200,
                                          httpVersion: "1.1",
                                          headerFields: nil)!

        let cachedRequest = CachedURLResponse(response: urlResponse, data: responseData)
        URLCache.shared.storeCachedResponse(cachedRequest, for: request)

        let notOwnRequest = URLRequest(url: URL(string: "http://example.test/usr?ud=321")!)
        let model = UrlNetworkRequest(urlRequest: notOwnRequest)

        // Act


        var expected: Error?

        testNode.process(model).onCompleted { data in
            XCTFail("\(data)")
        }.onError { error in
            expected = error
        }

        // Assert

        guard let guardedData = expected as? BaseUrlCacheReaderError else {
            XCTFail("\(expected.debugDescription)")
            return
        }

        XCTAssert(BaseUrlCacheReaderError.cantLoadDataFromCache == guardedData)
    }

    public func testThatNotJsonReturnSerializationError() {

        // Arrange

        let url = URL(string: "http://example.test")!
        let request = URLRequest(url: url)
        let model = UrlNetworkRequest(urlRequest: request)
        let testNode = UrlCacheReaderNode(needsToThrowError: true)

        URLCache.shared.removeAllCachedResponses()

        let responseData = "{1:1}".data(using: .utf8)!

        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: nil)!

        let cachedRequest = CachedURLResponse(response: urlResponse, data: responseData)
        URLCache.shared.storeCachedResponse(cachedRequest, for: request)


        // Act

        var expected: Error?

        testNode.process(model).onCompleted { data in
            XCTFail("\(data)")
        }.onError { error in
            expected = error
        }

        // Assert

        guard let guardedData = expected as? BaseUrlCacheReaderError else {
            XCTFail("\(expected.debugDescription)")
            return
        }

        XCTAssert(BaseUrlCacheReaderError.cantSerializeJson == guardedData)
    }

    public func testThatBadJsonReturnSerializationError() {

        // Arrange

        let url = URL(string: "http://example.test")!
        let request = URLRequest(url: url)
        let model = UrlNetworkRequest(urlRequest: request)
        let testNode = UrlCacheReaderNode(needsToThrowError: true)

        URLCache.shared.removeAllCachedResponses()

        let responseData = "12345".data(using: .utf8)!

        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: nil)!

        let cachedRequest = CachedURLResponse(response: urlResponse, data: responseData)
        URLCache.shared.storeCachedResponse(cachedRequest, for: request)


        // Act

        var expected: Error?

        testNode.process(model).onCompleted { data in
            XCTFail("\(data)")
            }.onError { error in
                expected = error
        }

        // Assert

        guard let guardedData = expected as? BaseUrlCacheReaderError else {
            XCTFail("\(expected.debugDescription)")
            return
        }

        XCTAssert(BaseUrlCacheReaderError.cantCastToJson == guardedData)
    }
}
