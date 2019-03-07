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
import CoreNetKit

public class TokenRefresherNodeTests: XCTestCase {

    class NodeStub: Node<Void, Void> {

        var countOfCals = 0

        override func process(_ data: Void) -> Observer<Void> {
            return Observer<Void>.emit(data: data).dispatchOn(.global(qos: .userInteractive)).map {
                print("kek")
                self.countOfCals += 1
                sleep(2)
                return ()
            }
        }
    }

    func testThatAllResponseEmited() {

        let testedNode = TokenRefresherNode(tokenRefreshChain: NodeStub())

        var counter = 0
        let countOfRequests = 9
        let exp = self.expectation(description: "\(#function)")

        for _ in 0..<countOfRequests {
            testedNode.process(()).onCompleted {
                counter += 1
            }
        }

        testedNode.process(()).onCompleted {
            exp.fulfill()
        }

        self.waitForExpectations(timeout: 3, handler: nil)

        XCTAssertEqual(countOfRequests, counter)
    }

    func testThatTokenUpdateCalledOnce() {

        let tokenUpdater = NodeStub()
        let testedNode = TokenRefresherNode(tokenRefreshChain: tokenUpdater)

        let countOfRequests = 9
        let exp = self.expectation(description: "\(#function)")

        for _ in 0..<countOfRequests {
            _ = testedNode.process(())
        }

        testedNode.process(()).onCompleted {
            exp.fulfill()
        }

        self.waitForExpectations(timeout: 3, handler: nil)

        XCTAssertEqual(tokenUpdater.countOfCals, 1)
    }
}
