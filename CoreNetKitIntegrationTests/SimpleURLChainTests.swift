//
//  SimpleChainTests.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 28/01/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import CoreNetKit

public class SimpleURLChainTests: XCTestCase {

    public func testDefaultURLChainWorkSuccess() {

        // Arrange

        let chainRoot: Node<EmptyRequest, [User]> = Chains.defaultChain(params:
            TransportUrlParameters(method: .get, url: Infrastructure.getUsersURL, headers: [String: String]()))

        // Act

        var result: [User]?
        var resultError: Error?

        let exp = self.expectation(description: "sdf")

        chainRoot.process(EmptyRequest())
            .onCompleted { (user) in
                result = user
                exp.fulfill()
            }.onError { (error) in
                resultError = error
                exp.fulfill()
            }

        waitForExpectations(timeout: 5, handler: nil)

        // Assert

        XCTAssertNotNil(result)
        XCTAssertNil(resultError, resultError!.localizedDescription)
    }

}
