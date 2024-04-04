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

final class FormUrlCodingTests: XCTestCase {

    func testFormUrlEncodedRequestCompleteSuccess() {
        // Arrange

        let chainRoot: any AsyncNode<AuthModel, Credentials> = UrlChainsBuilder()
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

        chainRoot.processLegacy(authModel)
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

    func testFormUrlEncodedRequestCompleteFailure() {
        // Arrange

        let chainRoot: any AsyncNode<AuthModel, Credentials> = UrlChainsBuilder()
            .route(.post, Routes.authWithFormUrl)
            .build()
        
        // Act

        var result: Credentials?
        var resultError: Error?

        let authModel = AuthModel(type: "badType", secret: "BadSecret")

        let exp = self.expectation(description: "\(#function)")

        chainRoot.processLegacy(authModel)
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
    
    func testAsyncProcess_FormUrlEncodedRequestCompleteSuccess() async throws {
        // given
        
        let authModel = AuthModel(type: "type", secret: "secret")
        let expectedAccessToken = "token"
        let expectedRefeshToken = "token"

        let chainRoot: any AsyncNode<AuthModel, Credentials> = UrlChainsBuilder()
            .route(.post, Routes.authWithFormUrl)
            .encode(as: .urlQuery)
            .build()

        // when

        let result = await chainRoot.process(authModel, logContext: LoggingContextMock())

        // then
        
        let resultValue = try XCTUnwrap(result.value)

        XCTAssertEqual(resultValue.accessToken, expectedAccessToken)
        XCTAssertEqual(resultValue.refreshToken, expectedRefeshToken)
    }

    func testAsyncProcess_FormUrlEncodedRequestCompleteFailure() async throws {
        // given

        let authModel = AuthModel(type: "badType", secret: "BadSecret")
        let chainRoot: any AsyncNode<AuthModel, Credentials> = UrlChainsBuilder()
            .route(.post, Routes.authWithFormUrl)
            .build()
        
        // when

        let result = await chainRoot.process(authModel)

        // then
        
        let error = try XCTUnwrap(result.error as? ResponseHttpErrorProcessorNodeError)

        if case .badRequest = error {
            return
        } else {
            XCTFail("Не верный результат работы метода")
        }
    }
}
