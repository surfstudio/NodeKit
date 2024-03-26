//
//  ChainConfiguratorNodeTests.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 08/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit


extension DispatchQueue {
    static var currentLabel: String {
        return String(validatingUTF8: __dispatch_queue_get_label(nil)) ?? ""
    }
}


public class ChainConfiguratorNodeTests: XCTestCase {


    class NextStub: Node {

        var queueLabel = ""

        func process(_ data: Void) -> Observer<Void> {
            self.queueLabel = DispatchQueue.currentLabel
            return .emit(data: data)
        }
    }


    public func testNextNodeDispatchedInBackground() {

        // Arrange

        let next = NextStub()

        let testedNode = ChainConfiguratorNode(next: next)

        // Act

        let exp = self.expectation(description: "\(#function)")

        _ = testedNode.process(()).onCompleted {
            exp.fulfill()
        }

        self.waitForExpectations(timeout: 2, handler: nil)

        // Assert

        XCTAssertEqual(next.queueLabel, "com.apple.root.user-initiated-qos")
    }

    public func testNextNodeDispatchedInMain() {

        // Arrange

        let testedNode = ChainConfiguratorNode(next: NextStub())
        var currentQueueLabel = ""

        // Act

        let exp = self.expectation(description: "\(#function)")

        _ = testedNode.process(()).onCompleted {
            currentQueueLabel = DispatchQueue.currentLabel
            exp.fulfill()
        }

        self.waitForExpectations(timeout: 2, handler: nil)

        // Assert

        XCTAssertEqual(currentQueueLabel, "com.apple.main-thread")
    }

}
