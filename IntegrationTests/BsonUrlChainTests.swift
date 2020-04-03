//
//  BsonUrlChainTests.swift
//  IntegrationTests
//
//  Created by Vladislav Krupenko on 03.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

public class BsonUrlChainTests: XCTestCase {

    public func testPostRequest() {

        // Arrange

        let chainRoot: Node<UserBsonEntity, Void> = BsonChain()
            .route(.post, Routes.bson)
            .build()

        let userEntity = UserBsonEntity(id: "409", firstName: "Freeze", lastName: "John")

        // Act

        var resultError: Error?

        let exp = self.expectation(description: "\(#function)")

        chainRoot.process(userEntity)
            .onCompleted { _ in
                exp.fulfill()
            }.onError { error in
                resultError = error
                exp.fulfill()
            }

        waitForExpectations(timeout: 3, handler: nil)

        // Assert

        XCTAssertNotNil(resultError)
        XCTAssertNil(nil, "Server return unexpeted response")
        XCTAssertTrue(resultError as? CustomServerProcessorNodeError == CustomServerProcessorNodeError.userExist)
    }

}
