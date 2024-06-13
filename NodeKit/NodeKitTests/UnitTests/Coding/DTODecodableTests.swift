//
//  DTODecodableTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class DTODecodableTests: XCTestCase {
    
    // MARK: - Lifecycle
    
    override func tearDown() {
        super.tearDown()
        DTODecodableMock.flush()
    }
    
    // MARK: - Tests
    
    func testFromDto_whenOptionalIsNil_thenNilReceived() {
        // given
        
        var result: DTODecodableMock?
        var receivedError: Error?
        
        // then
        
        do {
            result = try DTODecodableMock?.from(dto: nil)
        } catch {
            receivedError = error
        }
        
        // then
        
        XCTAssertNil(result)
        XCTAssertNil(receivedError)
    }
    
    func testFromDto_whenOptionalIsNotNil_thenFromRawCalled() throws {
        // given
        
        let expectedInput = RawDecodableMock()
        
        DTODecodableMock.stubbedFromResult = .success(.init())
        
        // then
        
        _ = try? DTODecodableMock?.from(dto: expectedInput)
        
        // then
        
        let input = try XCTUnwrap(DTODecodableMock.invokedFromParameter)
        
        XCTAssertEqual(DTODecodableMock.invokedFromCount, 1)
        XCTAssertTrue(input === expectedInput)
    }
    
    func testFromDto_withDecodingError_thenErrorReceived() throws {
        // given
        
        var result: DTODecodableMock?
        var receivedError: Error?
        
        DTODecodableMock.stubbedFromResult = .failure(MockError.firstError)
        
        // then
        
        do {
            result = try DTODecodableMock?.from(dto: .init())
        } catch {
            receivedError = error
        }
        
        // then
        
        let error = try XCTUnwrap(receivedError as? MockError)
        
        XCTAssertNil(result)
        XCTAssertEqual(error, .firstError)
    }
    
    func testFromDto_withDecodingSuccess_thenSuccessReceived() throws {
        // given
        
        var result: DTODecodableMock?
        var receivedError: Error?
        
        let expectedResult = DTODecodableMock()
        
        DTODecodableMock.stubbedFromResult = .success(expectedResult)
        
        // then
        
        do {
            result = try DTODecodableMock?.from(dto: .init())
        } catch {
            receivedError = error
        }
        
        // then
        
        let value = try XCTUnwrap(result)
        
        XCTAssertNil(receivedError)
        XCTAssertTrue(value === expectedResult)
    }
}
