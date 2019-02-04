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

        let chainRoot: Node<EmptyModel, [User]> = Chains.defaultChain(params:
            TransportUrlParameters(method: .get, url: Infrastructure.getUsersURL, headers: [String: String]()))

        let id = "id"
        let lastName = "Fry"
        let firstName = "Philip"

        // Act

        var result: [User]?
        var resultError: Error?

        let exp = self.expectation(description: "\(#function)")

        chainRoot.process(EmptyModel())
            .onCompleted { (user) in
                result = user
                exp.fulfill()
            }.onError { (error) in
                resultError = error
                exp.fulfill()
            }

        waitForExpectations(timeout: 3, handler: nil)

        // Assert

        XCTAssertNotNil(result)
        XCTAssertNil(resultError, resultError!.localizedDescription)
        XCTAssertEqual(result!.count, 4)

        for index in 0..<result!.count {
            XCTAssertEqual(result![index].id, "\(id)\(index)")
            XCTAssertEqual(result![index].lastName, "\(lastName)\(index)")
            XCTAssertEqual(result![index].firstName, "\(firstName)\(index)")
        }
    }
}
