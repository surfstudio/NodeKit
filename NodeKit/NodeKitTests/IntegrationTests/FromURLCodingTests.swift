//
//  FromURLCodingTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Foundation
import XCTest

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

    func testChain_withFormURLEncoded_thenSuccessReceived() async throws {
        // given

        let builder = URLChainBuilder<Routes>(serviceChainProvider: URLServiceChainProviderMock())
        let authModel = AuthModel(type: "type", secret: "secret")
        
        // when
        
        let result: NodeResult<Credentials> = await builder
            .route(.post, .authWithFormURL)
            .encode(as: .urlQuery)
            .build()
            .process(authModel)

        // then
        
        let value = try XCTUnwrap(result.value)

        XCTAssertEqual(value.accessToken, "stubbedAccessToken")
        XCTAssertEqual(value.refreshToken, "stubbedRefreshToken")
    }

    func testChain_withFormURLEncodedBadRequest_thenFailureReceived() async throws {
        // given

        let builder = URLChainBuilder<Routes>(serviceChainProvider: URLServiceChainProviderMock())
        let authModel = AuthModel(type: "badType", secret: "BadSecret")
        
        // when

        let result: NodeResult<Credentials> = await builder
            .route(.post, .authWithFormURL)
            .build()
            .process(authModel)

        // then
        
        let error = try XCTUnwrap(result.error as? ResponseHttpErrorProcessorNodeError)
        
        if case .badRequest(let data) = error {
            XCTAssertTrue(data.isEmpty)
        } else {
            XCTFail("Не верный результат работы метода")
        }
    }
}
