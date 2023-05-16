//
//  IfConnectionFailedFromCacheNodeTests.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 31/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

public class IfConnectionFailedFromCacheNodeTests: XCTestCase {

    private class NextStub: Node<URLRequest, Json> {

        var numberOfCalls: Int
        var lambda: () -> Observer<Json>

        init(with lambda: @escaping () -> Observer<Json>) {
            self.lambda = lambda
            self.numberOfCalls = 0
        }

        override func process(_ data: URLRequest) -> Observer<Json> {
            self.numberOfCalls += 1

            return self.lambda()
        }
    }

    class ReaderStub: Node<UrlNetworkRequest, Json> {

        var numberOfCalls = 0

        override func process(_ data: UrlNetworkRequest) -> Observer<Json> {

            self.numberOfCalls += 1

            return .emit(data: Json())
        }
    }

    public func testThatNodeWorkInCaseOfBadInternet() {

        // Arrange

        let next = NextStub(with: {
            return .emit(error: NSError(domain: "app.network", code: -1009, userInfo: nil))
        })

        let reader = ReaderStub()
        let mapper = TechnicaErrorMapperNode(next: next)
        let testNode = IfConnectionFailedFromCacheNode(next: mapper, cacheReaderNode: reader)

        let request = URLRequest(url: URL(string: "test.ex.temp")!)

        // Act

        _ = testNode.process(request)

        // Assert

        XCTAssertEqual(next.numberOfCalls, 1)
        XCTAssertEqual(reader.numberOfCalls, 1)
    }

    public func testThatNodeWorkInCaseOfGoodInternet() {
        // Arrange

        let next = NextStub(with: {
            return .emit(data: Json())
        })

        let reader = ReaderStub()
        let mapper = TechnicaErrorMapperNode(next: next)
        let testNode = IfConnectionFailedFromCacheNode(next: mapper, cacheReaderNode: reader)

        let request = URLRequest(url: URL(string: "test.ex.temp")!)

        // Act

        _ = testNode.process(request)

        // Assert

        XCTAssertEqual(next.numberOfCalls, 1)
        XCTAssertEqual(reader.numberOfCalls, 0)
    }

}
