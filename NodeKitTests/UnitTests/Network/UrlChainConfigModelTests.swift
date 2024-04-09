//
//  UrlChainConfigModelTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class UrlChainConfigModelTests: XCTestCase {
    
    // MARK: - Tests
    
    func testUrlChainConfigModel_withCustomParameters_thenCustomParametersReceived() throws {
        // given
        
        let model = UrlChainConfigModel(
            method: .options,
            route: UrlRouteProviderMock(),
            metadata: ["TestKey": "TestValue"],
            encoding: .urlQuery
        )
        
        // when
        
        let method = model.method
        let route = model.route
        let metadata = model.metadata
        let encoding = model.encoding
        
        // then
        
        let receivedRoute = try XCTUnwrap(route as? UrlRouteProviderMock)
        let expectedRoute = try XCTUnwrap(model.route as? UrlRouteProviderMock)
        
        XCTAssertEqual(method, model.method)
        XCTAssertTrue(receivedRoute === expectedRoute)
        XCTAssertEqual(metadata, model.metadata)
        XCTAssertEqual(encoding, model.encoding)
    }
    
    func testUrlChainConfigModel_withDefaultParameters_thenDefaultParametersReceived() throws {
        // given
        
        let model = UrlChainConfigModel(
            method: .options,
            route: UrlRouteProviderMock()
        )
        
        // when
        
        let method = model.method
        let route = model.route
        let metadata = model.metadata
        let encoding = model.encoding
        
        // then
        
        
        let receivedRoute = try XCTUnwrap(route as? UrlRouteProviderMock)
        let expectedRoute = try XCTUnwrap(model.route as? UrlRouteProviderMock)
        
        XCTAssertEqual(method, model.method)
        XCTAssertTrue(receivedRoute === expectedRoute)
        XCTAssertTrue(metadata.isEmpty)
        XCTAssertEqual(encoding, .json)
    }
}
