//
//  EmptyResponseMappingTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Foundation
import XCTest

final class EmptyResponseMappingTests: XCTestCase {
    
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

    /// We send request on server and await response with empty array in body
    /// In this test we assert that this resposne body will seccessfully parse in array of entities
    func testDefaultChainArrSucessParseResponseInCaseOfEmptyArray() async throws {
        // given

        let builder = URLChainBuilder<Routes>(serviceChainProvider: URLServiceChainProviderMock())
        let chainRoot: AnyAsyncNode<Void, [User]> = builder
            .route(.get, .emptyUsers)
            .build()

        // when

        let result: NodeResult<[User]> = await chainRoot.process()

        // then
        
        let value = try XCTUnwrap(result.value)

        XCTAssertTrue(value.isEmpty)
    }

    func testArraySuccessMappingWithNoContentResponse() async throws {
        // given
        
        let builder = URLChainBuilder<Routes>(serviceChainProvider: URLServiceChainProviderMock())
        let chainRoot: AnyAsyncNode<Void, [User]> = builder
            .route(.get, Routes.emptyUsersWith204)
            .build()

        // when

        let result: NodeResult<[User]> = await chainRoot.process()

        // then

        let value = try XCTUnwrap(result.value)

        XCTAssertTrue(value.isEmpty)
    }
}
