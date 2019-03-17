//
//  UrlETagUrlCacheTriggerNodeTests.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import CoreNetKit

public class UrlETagUrlCacheTriggerNodeTests: XCTestCase {

    class TransportMock: ResponseProcessingLayerNode {

        var numberOfCalls = 0

        override func process(_ data: UrlDataResponse) -> Observer<Json> {
            self.numberOfCalls += 1
            return .emit(data: Json())
        }
    }

    class CacheSaverMock: Node<UrlNetworkRequest, Json> {

        var numberOfCalls = 0

        override func process(_ data: UrlNetworkRequest) -> Observer<Json> {

            self.numberOfCalls += 1

            return .emit(data: Json())
        }
    }

    public func testNextCalledIfDataIsNotNotModified() {
        // Arrange

        let transportMock = TransportMock()
        let cacheSaverMock = CacheSaverMock()

        let testedNode = UrlNotModifiedTriggerNode(next: transportMock, cacheReader: cacheSaverMock)

        let url = URL(string: "http://UrlETagUrlCacheTriggerNode.test/testNextCalledIfDataIsNotNotModified")!
        let response = Utils.getMockUrlDataResponse(url: url)

        let expectation = self.expectation(description: "\(#function)")

        // Act

        var numberOfCalls = 0

        testedNode.process(response).onCompleted { _ in
            numberOfCalls += 1
            expectation.fulfill()
        }.onError { _ in
            numberOfCalls += 1
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1, handler: nil)

        // Assert

        XCTAssertEqual(numberOfCalls, 1)
        XCTAssertEqual(transportMock.numberOfCalls, 1)
        XCTAssertEqual(cacheSaverMock.numberOfCalls, 0)
    }

    public func testNextCalledIfDataNotModified() {
        // Arrange

        let transportMock = TransportMock()
        let cacheSaverMock = CacheSaverMock()

        let testedNode = UrlNotModifiedTriggerNode(next: transportMock, cacheReader: cacheSaverMock)

        let url = URL(string: "http://UrlETagUrlCacheTriggerNode.test/testNextCAlledIfDataIsNotNotModified")!
        let response = Utils.getMockUrlDataResponse(url: url, statusCode: 304)

        let expectation = self.expectation(description: "\(#function)")

        // Act

        var numberOfCalls = 0

        testedNode.process(response).onCompleted { _ in
            numberOfCalls += 1
            expectation.fulfill()
            }.onError { _ in
                numberOfCalls += 1
                expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1, handler: nil)

        // Assert

        XCTAssertEqual(numberOfCalls, 1)
        XCTAssertEqual(transportMock.numberOfCalls, 0)
        XCTAssertEqual(cacheSaverMock.numberOfCalls, 1)
    }

}
