//
//  AbortingTests.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 04/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import CoreNetKit

public class AbortingTests: XCTestCase {


    class MockAborter: Node<Void, Void>, Aborter {

        var cancelCallsNumber = 0

        override func process(_ data: Void) -> Context<Void> {
            let context = Context<Void>()

            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
                context.emit(data: ())
            }

            return context
        }

        func cancel() {
            self.cancelCallsNumber += 1
        }
    }


    public func testAbortPassedSuccess() {

        // Arrange

        let abortedNode = MockAborter()
        let aborterNode = AborterNode<Void, Void>(next: abortedNode, aborter: abortedNode)

        // Act

        let exp = self.expectation(description: "\(#function)")


        var completedCalls = 0
        var errorCalls = 0
        var canceledCalls = 0
        var deferCalls = 0

        let context = aborterNode
            .process(())
            .onCompleted { val in
                completedCalls += 1
                exp.fulfill()
            }.onError { val in
                errorCalls += 1
                exp.fulfill()
            }.onCanceled {
                canceledCalls += 1
                exp.fulfill()
            }.defer {
                deferCalls += 1
                exp.fulfill()
            }


        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            context.cancel()
        }

        waitForExpectations(timeout: 10, handler: nil)

        // Assert

        XCTAssertEqual(canceledCalls, 1)
        XCTAssertEqual(abortedNode.cancelCallsNumber, 1)

        XCTAssertEqual(completedCalls, 0)
        XCTAssertEqual(errorCalls, 0)
        XCTAssertEqual(errorCalls, 0)
    }
}

