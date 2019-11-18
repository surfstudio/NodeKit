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
import NodeKit

@available(iOS 13.0, *)
public class SimpleURLChainTestsCombine: XCTestCase {

    public func testDefaultURLChainWorkSuccess() {

        // Arrange

        let chainRoot: Node<Void, [User]> = UrlChainsBuilder().default(with: .init(method: .get,
                                                                               route: Routes.users))

        let id = "id"
        let lastName = "Fry"
        let firstName = "Philip"

        // Act

        var result: [User]?
        var resultError: Error?

        let exp = self.expectation(description: "\(#function)")

        let t = chainRoot.make()
            .sink(receiveCompletion: {dat in
                print(dat)
                exp.fulfill()
            }, receiveValue: { (usrs) in
                result = usrs
                exp.fulfill()
            })

        waitForExpectations(timeout: 1000, handler: nil)

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
