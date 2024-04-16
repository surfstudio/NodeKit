//
//  ServerRequestsManagerTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

import XCTest

final class ServerRequestsManagerTests: XCTestCase {
    
    
    // MARK: - Sut
    
    private var sut: ServerRequestsManager!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        sut = ServerRequestsManager.shared
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    // MARK: - Tests
    
    func testManager_thenSessionManagerWithCorrectConfiguration() {
        // when
        
        let configuration = sut.manager.configuration
        
        // then
        
        XCTAssertEqual(configuration.timeoutIntervalForResource, 180)
        XCTAssertEqual(configuration.timeoutIntervalForRequest, 180)
        XCTAssertEqual(configuration.requestCachePolicy, .reloadIgnoringCacheData)
        XCTAssertNil(configuration.urlCache)
    }
}
