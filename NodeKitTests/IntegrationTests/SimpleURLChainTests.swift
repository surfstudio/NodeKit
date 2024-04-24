//
//  SimpleURLChainTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

final class SimpleURLChainTests: XCTestCase {
    
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

    func testDefaultURLChainWorkSuccess() async throws {
        // given

        let chainRoot: any AsyncNode<Void, [User]> = UrlChainsBuilder(serviceChain: UrlServiceChainBuilderMock())
            .set(metadata: ["TestHeader":"testHeaderValue"])
            .route(.get, Routes.users)
            .build()

        let id = "id"
        let lastName = "Fry"
        let firstName = "Philip"

        // when
        
        let result = await chainRoot.process()

        // then
        
        let value = try XCTUnwrap(result.value)

        XCTAssertEqual(value.count, 4)

        for index in 0..<value.count {
            XCTAssertEqual(value[index].id, "\(id)\(index)")
            XCTAssertEqual(value[index].lastName, "\(lastName)\(index)")
            XCTAssertEqual(value[index].firstName, "\(firstName)\(index)")
        }
    }

    func testURLChainWorkSuccessWithQueryEncoding() async throws {
        // given

        let id = "id"
        let lastName = "Bender"
        let firstName = "Rodrigez"

        // when

        let result: NodeResult<[User]> = await UrlChainsBuilder<Routes>(serviceChain: UrlServiceChainBuilderMock())
            .set(query: ["stack": "left", "sort": false])
            .set(boolEncodingStartegy: .asBool)
            .route(.get, .users)
            .build()
            .process()

        // then

        let value = try XCTUnwrap(result.value)

        XCTAssertEqual(value.count, 4)

        for index in 0..<value.count {
            XCTAssertEqual(value[index].id, "\(id)\(index)")
            XCTAssertEqual(value[index].lastName, "\(lastName)\(index)")
            XCTAssertEqual(value[index].firstName, "\(firstName)\(index)")
        }
    }
}

