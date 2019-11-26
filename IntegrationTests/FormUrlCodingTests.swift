//
//  FormUrlCodingTests.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

public class FormUrlCodingTests: XCTestCase {

    public func testFormUrlEncodedRequestCompleteSuccess() {
        // Arrange

        let chainRoot: Node<AuthModel, Credentials> = UrlChainsBuilder()
            .route(.post, Routes.authWithFormUrl)
            .encode(as: .urlQuery)
            .build()

        // Act

        var result: Credentials?
        var resultError: Error?

        let authModel = AuthModel(type: "type", secret: "secret")

        let expectedAccessToken = "token"
        let expectedRefeshToken = "token"

        let exp = self.expectation(description: "\(#function)")

        chainRoot.process(authModel)
            .onCompleted { (credentials) in
                result = credentials
                exp.fulfill()
            }.onError { (error) in
                resultError = error
                exp.fulfill()
        }

        waitForExpectations(timeout: 3, handler: nil)

        // Assert

        XCTAssertNotNil(result)
        XCTAssertNil(resultError, resultError!.localizedDescription)
        XCTAssertEqual(result!.accessToken, expectedAccessToken)
        XCTAssertEqual(result!.refreshToken, expectedRefeshToken)
    }

    public func testFormUrlEncodedRequestCompleteFailure() {
        // Arrange

        let chainRoot: Node<AuthModel, Credentials> = UrlChainsBuilder()
            .route(.post, Routes.authWithFormUrl)
            .build()
        
        // Act

        var result: Credentials?
        var resultError: Error?

        let authModel = AuthModel(type: "badType", secret: "BadSecret")

        let exp = self.expectation(description: "\(#function)")

        chainRoot.process(authModel)
            .onCompleted { (credentials) in
                result = credentials
                exp.fulfill()
            }.onError { (error) in
                resultError = error
                exp.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        // Assert

        XCTAssertNil(result)
        XCTAssertNotNil(resultError)

        guard case ResponseHttpErrorProcessorNodeError.badRequest = resultError! else {
            XCTFail()
            return
        }
    }
}
