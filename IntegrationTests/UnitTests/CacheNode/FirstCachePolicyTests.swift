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
import NodeKit

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

    public func testThatNextNodeCalledInCaseOfBadInput() {

        // Arrange

        let next = NextStub()
        let reader = ReaderStub()

        let node = FirstCachePolicyNode(cacheReaderNode: reader, next: next)

        // Act

        let expectation = self.expectation(description: "\(#function)")

        var completedCalls = 0
        
        let request = RawUrlRequest(dataRequest: nil)

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
        let request = RawUrlRequest(dataRequest: URLRequest(url: URL(string: "test.ex.temp")!))

        node.process(request).onCompleted { data in
            completedCalls += 1
            if completedCalls == 2 {
                expectation.fulfill()
            }
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
