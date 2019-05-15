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
import Alamofire

@testable
import NodeKit

public class IfConnectionFailedFromCacheNodeTests: XCTestCase {

    private class NextStub: Node<RawUrlRequest, Json> {

        var numberOfCalls: Int
        var lambda: () -> Observer<Json>

        init(with lambda: @escaping () -> Observer<Json>) {
            self.lambda = lambda
            self.numberOfCalls = 0
        }

        override func process(_ data: RawUrlRequest) -> Observer<Json> {
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

    class StubRequest: DataRequest {

        override var request: URLRequest? {
            return self.stubRequest
        }

        let stubRequest: URLRequest?

        init(request: URLRequest?) {
            self.stubRequest = request
            super.init(convertible: request!, underlyingQueue: .global(), serializationQueue: .main, eventMonitor: nil, interceptor: nil, delegate: Session.default)
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

        let model = StubRequest(request: URLRequest(url: URL(string: "test.ex.temp")!))
        let rawUrlRequest = RawUrlRequest(dataRequest: model)

        // Act

        _ = testNode.process(rawUrlRequest)

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

        let model = StubRequest(request: URLRequest(url: URL(string: "test.ex.temp")!))
        let rawUrlRequest = RawUrlRequest(dataRequest: model)

        // Act

        _ = testNode.process(rawUrlRequest)

        // Assert

        XCTAssertEqual(next.numberOfCalls, 1)
        XCTAssertEqual(reader.numberOfCalls, 0)
    }
}
