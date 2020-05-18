//
//  UrlETagReaderNodeTests.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

public class UrlETagReaderNodeTests: XCTestCase {

    class MockNode: Node<TransportUrlRequest, Json> {

        var tag: String? = nil

        var key = ETagConstants.eTagRequestHeaderKey

        override func process(_ data: TransportUrlRequest) -> Observer<Json> {
            tag = data.headers[self.key]

            return .emit(data: Json())
        }
    }

    public func testReadSuccess() {

        // Arrange

        let mock = MockNode()
        let node = UrlETagReaderOutput(next: mock)
        let tag = "\(NSObject().hash)"

        let url = URL(string: "http://UrlETagReaderNodeTests/testReadSuccess")!
        let params = TransportUrlParameters(method: .get, url: url)
        let request = TransportUrlRequest(with:params , raw: Data())

        let expectation = self.expectation(description: "\(#function)")

        defer {
            UserDefaults.etagStorage?.removeObject(forKey: url.absoluteString)
        }

        // Act

        UserDefaults.etagStorage?.set(tag, forKey: url.absoluteString)

        var callCount = 0

        node.process(request).onCompleted { _ in
            callCount += 1
            expectation.fulfill()
        }.onError { _ in
            callCount += 1
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1, handler: nil)

        // Assert

        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(mock.tag, tag)
    }

    public func testNotReadIfTagNotExist() {

        // Arrange

        let mock = MockNode()
        let node = UrlETagReaderOutput(next: mock)

        let url = URL(string: "http://UrlETagReaderNodeTests/testNotReadIfTagNotExist")!
        let params = TransportUrlParameters(method: .get, url: url)
        let request = TransportUrlRequest(with:params , raw: Data())

        let expectation = self.expectation(description: "\(#function)")

        // Act

        UserDefaults.etagStorage?.removeObject(forKey: url.absoluteString)

        var callCount = 0

        node.process(request).onCompleted { _ in
            callCount += 1
            expectation.fulfill()
            }.onError { _ in
                callCount += 1
                expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1, handler: nil)

        // Assert

        XCTAssertEqual(callCount, 1)
        XCTAssertNil(mock.tag)
    }

    public func testReadSuccessWithCustomKey() {

        // Arrange

        let key = "My-Custom-ETag-Key"
        let mock = MockNode()
        mock.key = key
        let node = UrlETagReaderOutput(next: mock, etagHeaderKey: key)
        let tag = "\(NSObject().hash)"


        let url = URL(string: "http://UrlETagReaderNodeTests/testReadSuccessWithCustomKey")!
        let params = TransportUrlParameters(method: .get, url: url)
        let request = TransportUrlRequest(with:params , raw: Data())

        let expectation = self.expectation(description: "\(#function)")

        defer {
            UserDefaults.etagStorage?.removeObject(forKey: url.absoluteString)
        }

        // Act

        UserDefaults.etagStorage?.set(tag, forKey: url.absoluteString)

        var callCount = 0

        node.process(request).onCompleted { _ in
            callCount += 1
            expectation.fulfill()
            }.onError { _ in
                callCount += 1
                expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1, handler: nil)

        // Assert

        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(mock.tag, tag)
    }

}
