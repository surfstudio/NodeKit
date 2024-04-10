//
//  RawDecodableTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class RawDecodableTests: XCTestCase {
    
    // MARK: - Lifecycle
    
    override func tearDown() {
        super.tearDown()
        RawDecodableMock.flush()
    }
    
    // MARK: - Tests
    
    func testFromRaw_whenOptionalIsNil_thenNilReceived() {
        // given
        
        var result: RawDecodableMock?
        var receivedError: Error?
        
        // then
        
        do {
            result = try RawDecodableMock?.from(raw: nil)
        } catch {
            receivedError = error
        }
        
        // then
        
        XCTAssertNil(result)
        XCTAssertNil(receivedError)
    }
    
    func testFromRaw_whenOptionalIsNotNil_thenFromRawCalled() throws {
        // given
        
        let expectedInput = ["TestKey": "TestValue"]
        
        RawDecodableMock.stubbedFromResult = .success(.init())
        
        // then
        
        _ = try? RawDecodableMock?.from(raw: expectedInput)
        
        // then
        
        let input = try XCTUnwrap(RawDecodableMock.invokedFromParameter as? [String: String])
        
        XCTAssertEqual(RawDecodableMock.invokedFromCount, 1)
        XCTAssertEqual(input, expectedInput)
    }
    
    func testFromRaw_withDecodingError_thenErrorReceived() throws {
        // given
        
        var result: RawDecodableMock?
        var receivedError: Error?
        
        RawDecodableMock.stubbedFromResult = .failure(MockError.firstError)
        
        // then
        
        do {
            result = try RawDecodableMock?.from(raw: [:])
        } catch {
            receivedError = error
        }
        
        // then
        
        let error = try XCTUnwrap(receivedError as? MockError)
        
        XCTAssertNil(result)
        XCTAssertEqual(error, .firstError)
    }
    
    func testFromRaw_withDecodingSuccess_thenSuccessReceived() throws {
        // given
        
        var result: RawDecodableMock?
        var receivedError: Error?
        
        let expectedResult = RawDecodableMock()
        
        RawDecodableMock.stubbedFromResult = .success(expectedResult)
        
        // then
        
        do {
            result = try RawDecodableMock?.from(raw: [:])
        } catch {
            receivedError = error
        }
        
        // then
        
        let value = try XCTUnwrap(result)
        
        XCTAssertNil(receivedError)
        XCTAssertTrue(value === expectedResult)
    }
}
