//
//  UrlETagSaverNodeTests.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest
import Alamofire

@testable
import NodeKit

public class UrlETagSaverNodeTests: XCTestCase {

    public func testNodeSaveTag() {

        // Arrange

        let node = UrlETagSaverNode(next: nil)
        let url = URL(string: "http://urletagsaver.tests/testNodeSaveTag")!
        let tag = "\(NSObject().hash)"

        let data = Utils.getMockUrlProcessedResponse(url: url, headers: [ETagConstants.eTagResponseHeaderKey: tag])

        var callCount = 0

        let expectation = self.expectation(description: "\(#function)")

        defer {
            UserDefaults.etagStorage?.removeObject(forKey: url.absoluteString)
        }

        // Act

        node.process(data).onCompleted { model in
            callCount += 1
            expectation.fulfill()
        }.onError { error in
            callCount += 1
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1, handler: nil)

        guard let readedTag = UserDefaults.etagStorage?.string(forKey: url.absoluteString) else {
            XCTFail("Cant read tag from UD")
            return
        }

        // Assert

        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(readedTag, tag)
    }

    func testNodeNotSaveTag() {

        // Arrange

        let node = UrlETagSaverNode(next: nil)
        let url = URL(string: "http://urletagsaver.tests/testNodeNotSaveTag")!

        let data = Utils.getMockUrlProcessedResponse(url: url)

        var callCount = 0

        let expectation = self.expectation(description: "\(#function)")

        defer {
            UserDefaults.etagStorage?.removeObject(forKey: url.absoluteString)
        }

        // Act

        node.process(data).onCompleted { model in
            callCount += 1
            expectation.fulfill()
            }.onError { error in
                callCount += 1
                expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1, handler: nil)

        let readedTag = UserDefaults.etagStorage?.string(forKey: url.absoluteString)

        // Assert

        XCTAssertEqual(callCount, 1)
        XCTAssertNil(readedTag)
    }

    func testSaveWorkForCustomKey() {

        // Arrange


        let url = URL(string: "http://urletagsaver.tests/testSaveWorkForCustomKey")!
        let tag = "\(NSObject().hash)"
        let tagKey = "My-Custom-ETag-Key"

        let node = UrlETagSaverNode(next: nil, eTagHeaderKey: tagKey)

        let data = Utils.getMockUrlProcessedResponse(url: url, headers: [tagKey: tag])

        var callCount = 0

        let expectation = self.expectation(description: "\(#function)")

        defer {
            UserDefaults.etagStorage?.removeObject(forKey: url.absoluteString)
        }

        // Act

        node.process(data).onCompleted { model in
            callCount += 1
            expectation.fulfill()
            }.onError { error in
                callCount += 1
                expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1, handler: nil)

        guard let readedTag = UserDefaults.etagStorage?.string(forKey: url.absoluteString) else {
            XCTFail("Cant read tag from UD")
            return
        }

        // Assert

        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(readedTag, tag)
    }
}
