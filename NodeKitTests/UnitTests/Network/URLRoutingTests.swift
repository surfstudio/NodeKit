//
//  URLRoutingTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

import XCTest

final class URLRoutingTests: XCTestCase {
    
    // MARK: - Tests
    
    func testAppend_whenURLIsNil_thenErrorReceived() throws {
        // given
        
        let url: URL? = nil
        let appending = "/users"
        
        var result: URL?
        var receivedError: Error?
        
        // when
        
        do {
            result = try url + appending
        } catch {
            receivedError = error
        }
        
        // then
        
        let error = try XCTUnwrap(receivedError as? UrlRouteError)
        
        XCTAssertNil(result)
        XCTAssertEqual(error, .cantBuildUrl)
    }
    
    func testAppend_whenURLIsNotNil_thenNewURLReceived() throws {
        // given
        
        let url: URL = URL(string: "www.test.com")!
        let appending = "/users"
        
        var result: URL?
        var receivedError: Error?
        
        // when
        
        do {
            result = try url + appending
        } catch {
            receivedError = error
        }
        
        // then
        
        let value = try XCTUnwrap(result?.absoluteString)
        
        XCTAssertNil(receivedError)
        XCTAssertEqual(value, "www.test.com/users")
    }
}
