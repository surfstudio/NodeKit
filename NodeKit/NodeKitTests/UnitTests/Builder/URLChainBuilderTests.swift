//
//  URLChainBuilderTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 02.05.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class URLChainBuilderTests: XCTestCase {
    
    // MARK: - Sut
    
    private var sut: URLChainBuilder<URLRouteProviderMock>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        sut = URLChainBuilder<URLRouteProviderMock>()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    // MARK: - Tests
    
    func testSetQuery_thenQuerySet() throws {
        // given
        
        let expectedQuery = ["Test1": "Test2"]
        
        // when
        
        _ = sut.set(query: expectedQuery)
        
        // then
        
        let query = try XCTUnwrap(sut.config.query as? [String: String])
        
        XCTAssertEqual(query, expectedQuery)
    }
    
    func testBoolEncodingStartegy_thenBoolEncodingStartegySet() throws {
        // given
        
        let expectedStrategy: URLQueryBoolEncodingDefaultStartegy = .asBool
        
        // when
        
        _ = sut.set(boolEncodingStartegy: expectedStrategy)
        
        // then
        
        let startegy = try XCTUnwrap(sut.config.boolEncodingStartegy as? URLQueryBoolEncodingDefaultStartegy)
        XCTAssertEqual(startegy, expectedStrategy)
    }
    
    func testArrayEncodingStrategy_thenArrayEncodingStrategySet() throws {
        // given
        
        let expectedStrategy: URLQueryArrayKeyEncodingBracketsStartegy = .noBrackets
        
        // when
        
        _ = sut.set(arrayEncodingStrategy: expectedStrategy)
        
        // then
        
        let startegy = try XCTUnwrap(sut.config.arrayEncodingStrategy as? URLQueryArrayKeyEncodingBracketsStartegy)
        XCTAssertEqual(startegy, expectedStrategy)
    }
    
    func testDictEncodindStrategy_thenDictEncodindStrategySet() throws {
        // given
        
        class Mock: URLQueryDictionaryKeyEncodingStrategy {
            func encode(queryItemName: String, dictionaryKey: String) -> String {
                ""
            }
        }
        
        let expectedStrategy: Mock = Mock()
        
        // when
        
        _ = sut.set(dictEncodindStrategy: expectedStrategy)
        
        // then
        
        let startegy = try XCTUnwrap(
            sut.config.dictEncodindStrategy as? Mock
        )
        XCTAssertTrue(startegy === expectedStrategy)
    }
}
