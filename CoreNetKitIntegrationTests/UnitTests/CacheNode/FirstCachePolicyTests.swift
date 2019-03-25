//
//  FirstCachePolicyTests.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 24/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import Alamofire

@testable
import CoreNetKit

public class FirstCachePolicyTests: XCTestCase {

    private class NextStub: Node<RawUrlRequest, Json> {

        var numberOfCalls = 0

        override func process(_ data: RawUrlRequest) -> Observer<Json> {
            self.numberOfCalls += 1

            let result = Context<Json>()
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                result.emit(data: Json())
            })
            return result
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
            super.init(session: URLSession.shared, requestTask: .data(nil, nil))
        }
    }

    public func testThatNextNodeCalledInCaseOfBadInput() {

        // Arrange

        let next = NextStub()
        let reader = ReaderStub()

        print(DispatchQueue.currentLabel)

        let node = FirstCachePolicyNode(cacheReaderNode: reader, next: next)

        // Act

        let expectation = self.expectation(description: "\(#function)")

        var completedCalls = 0

        let request = RawUrlRequest(dataRequest: StubRequest(request: nil))

        node.process(request).onCompleted { data in
            completedCalls += 1
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 300) { (error) in
            guard let err = error else {
                return

            }
            XCTFail("\(err)")
        }

        // Assert

        XCTAssertEqual(completedCalls, 1)
        XCTAssertEqual(next.numberOfCalls, 1)
        XCTAssertEqual(reader.numberOfCalls, 0)
    }

    public func testThatNextNodeCalledInCaseOfGoodInput() {

        // Arrange

        let next = NextStub()
        let reader = ReaderStub()

        let node = FirstCachePolicyNode(cacheReaderNode: reader, next: next)

        // Act

        let expectation = self.expectation(description: "\(#function)")

        var completedCalls = 0

        let model = StubRequest(request: URLRequest(url: URL(string: "test.ex.temp")!))
        let request = RawUrlRequest(dataRequest: model)

        node.process(request).onCompleted { data in
            completedCalls += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 30, handler: nil)

        // Assert

        XCTAssertEqual(completedCalls, 2)
        XCTAssertEqual(next.numberOfCalls, 1)
        XCTAssertEqual(reader.numberOfCalls, 1)
    }
}
