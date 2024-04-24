//
//  FromURLCodingTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

final class FromURLCodingTests: XCTestCase {
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        URLResponsesStub.stubIntegrationTestsResponses()
    }
    
    override func tearDown() {
        super.tearDown()
        URLResponsesStub.flush()
    }
    
    // MARK: - Tests

    func testChain_withFormUrlEncoded_thenSuccessReceived() async throws {
        // given

        let sut: any AsyncNode<AuthModel, Credentials> = UrlChainsBuilder(serviceChain: UrlServiceChainBuilderMock())
            .route(.post, Routes.authWithFormUrl)
            .encode(as: .urlQuery)
            .build()
        
        let authModel = AuthModel(type: "type", secret: "secret")

        // when

        let result = await sut.process(authModel)

        // then
        
        let value = try XCTUnwrap(result.value)

        XCTAssertEqual(value.accessToken, "stubbedAccessToken")
        XCTAssertEqual(value.refreshToken, "stubbedRefreshToken")
    }

    func testChain_withFormUrlEncodedBadRequest_thenFailureReceived() async throws {
        // given

        let sut: any AsyncNode<AuthModel, Credentials> = UrlChainsBuilder(serviceChain: UrlServiceChainBuilderMock())
            .route(.post, Routes.authWithFormUrl)
            .build()
        
        let authModel = AuthModel(type: "badType", secret: "BadSecret")
        
        // when

        let result = await sut.process(authModel)

        // then
        
        let error = try XCTUnwrap(result.error as? ResponseHttpErrorProcessorNodeError)
        
        if case .badRequest(let data) = error {
            XCTAssertTrue(data.isEmpty)
        } else {
            XCTFail("Не верный результат работы метода")
        }
    }
}
