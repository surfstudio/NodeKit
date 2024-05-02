//
//  URLChainConfigModelTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class URLChainConfigModelTests: XCTestCase {
    
    // MARK: - Tests
    
    func testURLChainConfigModel_withCustomParameters_thenCustomParametersReceived() throws {
        // given
        
        let model = URLChainConfigModel(
            method: .options,
            route: URLRouteProviderMock(),
            metadata: ["TestKey": "TestValue"],
            encoding: .urlQuery
        )
        
        // when
        
        let method = model.method
        let route = model.route
        let metadata = model.metadata
        let encoding = model.encoding
        
        // then
        
        let receivedRoute = try XCTUnwrap(route as? URLRouteProviderMock)
        let expectedRoute = try XCTUnwrap(model.route as? URLRouteProviderMock)
        
        XCTAssertEqual(method, model.method)
        XCTAssertTrue(receivedRoute === expectedRoute)
        XCTAssertEqual(metadata, model.metadata)
        XCTAssertEqual(encoding, model.encoding)
    }
    
    func testURLChainConfigModel_withDefaultParameters_thenDefaultParametersReceived() throws {
        // given
        
        let model = URLChainConfigModel(
            method: .options,
            route: URLRouteProviderMock()
        )
        
        // when
        
        let method = model.method
        let route = model.route
        let metadata = model.metadata
        let encoding = model.encoding
        
        // then
        
        
        let receivedRoute = try XCTUnwrap(route as? URLRouteProviderMock)
        let expectedRoute = try XCTUnwrap(model.route as? URLRouteProviderMock)
        
        XCTAssertEqual(method, model.method)
        XCTAssertTrue(receivedRoute === expectedRoute)
        XCTAssertTrue(metadata.isEmpty)
        XCTAssertEqual(encoding, .json)
    }
}
