//
//  DictionaryDTOConvertibleTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class DictionaryDTOConvertibleTests: XCTestCase {
    
    // MARK: - Tests
    
    func testToRaw_thenCorrectJsonReceived() throws {
        // given
        
        let expectedJson = [
            "TestKey1": "TestValue1",
            "TestKey2": "TestValue2",
            "TestKey3": "TestValue3",
            "TestKey4": "TestValue4"
        ]
        let sut = expectedJson as Json
        
        // when
        
        let result = try sut.toRaw()
        
        // then
        
        let value = try XCTUnwrap(result as? [String: String])
        XCTAssertEqual(value, expectedJson)
    }
    
    func testFromRaw_thenCorrectDictionaryReceived() throws {
        // given
        
        let expectedJson = [
            "TestKey1": "TestValue1",
            "TestKey2": "TestValue2",
            "TestKey3": "TestValue3",
            "TestKey4": "TestValue4"
        ]
        let sut = expectedJson as Json
        
        // when
        
        let result = try [String: Any].from(raw: sut)
        
        // then
        
        let value = try XCTUnwrap(result as? [String: String])
        XCTAssertEqual(value, expectedJson)
    }
    
    func testFromDto_thenCorrectDictionaryReceived() throws {
        // given
        
        let expectedJson = [
            "TestKey1": "TestValue1",
            "TestKey2": "TestValue2",
            "TestKey3": "TestValue3",
            "TestKey4": "TestValue4"
        ]
        let sut = expectedJson as Json
        
        // when
        
        let result = try [String: Any].from(dto: sut)
        
        // then
        
        let value = try XCTUnwrap(result as? [String: String])
        XCTAssertEqual(value, expectedJson)
    }
    
    func testToDto_thenCorrectDictionaryReceived() throws {
        // given
        
        let expectedJson = [
            "TestKey1": "TestValue1",
            "TestKey2": "TestValue2",
            "TestKey3": "TestValue3",
            "TestKey4": "TestValue4"
        ]
        let sut = expectedJson as Json
        
        // when
        
        let result = try sut.toDTO()
        
        // then
        
        let value = try XCTUnwrap(result as? [String: String])
        XCTAssertEqual(value, expectedJson)
    }
}
