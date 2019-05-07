//
//  TokenRefresherNodeThreadSafetyTests.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 08/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

public class TokenRefresherNodeTests: XCTestCase {

    class NodeStub: Node<Void, Void> {

        var countOfCals = 0

        override func process(_ data: Void) -> Observer<Void> {

            let result = Context<Void>()

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
                self.countOfCals += 1
                result.emit(data: ())
            }

            return result
        }
    }

    func testThatAllResponseEmited() {

        // Arrange

        let testedNode = TokenRefresherNode(tokenRefreshChain: NodeStub())
        var counter = 0
        let countOfRequests = 9

        // Act

        let exp = self.expectation(description: "\(#function)")

        for _ in 0..<countOfRequests {
            testedNode.process(()).onCompleted {
                counter += 1
            }
        }

        testedNode.process(()).onCompleted {
            exp.fulfill()
        }

        self.waitForExpectations(timeout: 7, handler: nil)

        // Assert

        XCTAssertEqual(countOfRequests, counter)
    }

    func testThatTokenUpdateCalledOnce() {

        // Arrange

        let tokenUpdater = NodeStub()
        let testedNode = TokenRefresherNode(tokenRefreshChain: tokenUpdater)

        let countOfRequests = 9

        // Act

        let exp = self.expectation(description: "\(#function)")

        for _ in 0..<countOfRequests {
            _ = testedNode.process(())
        }

        testedNode.process(()).onCompleted {
            exp.fulfill()
        }

        self.waitForExpectations(timeout: 3, handler: nil)

        // Assert

        XCTAssertEqual(tokenUpdater.countOfCals, 1)
    }
}
