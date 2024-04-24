//
//  ArrayDTODecodableTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class ArrayDTODecodableTests: XCTestCase {
    
    // MARK: - Lifecycle
    
    override func tearDown() {
        super.tearDown()
        DTODecodableMock.flush()
    }
    
    // MARK: - Tests
    
    func testFromDTO_thenFromDTOCalledInEachElement() throws {
        // given
        
        let array: [RawDecodableMock] = [
            RawDecodableMock(),
            RawDecodableMock(),
            RawDecodableMock()
        ]
        
        DTODecodableMock.stubbedFromResult = .success(.init())
        
        // when
        
        _ = try? Array<DTODecodableMock>.from(dto: array)
        
        // then
        
        XCTAssertEqual(DTODecodableMock.invokedFromCount, array.count)
        
        DTODecodableMock.invokedFromParameterList.enumerated().forEach {
            XCTAssertTrue($0.element === array[$0.offset])
        }
    }
    
    func testFromDTO_whenDecodingFailure_thenFailureReceived() throws {
        // given
        
        let array: [RawDecodableMock] = [
            RawDecodableMock()
        ]
        
        var result: [DTODecodableMock]?
        var receivedError: Error?
        
        DTODecodableMock.stubbedFromResult = .failure(MockError.firstError)
        
        // when
        
        do {
            result = try [DTODecodableMock].from(dto: array)
        } catch {
            receivedError = error
        }
        
        // then
        
        let error = try XCTUnwrap(receivedError as? MockError)
        
        XCTAssertNil(result)
        XCTAssertEqual(error, .firstError)
    }
    
    func testFromDTO_whenDecodingSuccess_thenSuccessResultReceived() throws {
        // given
        
        let array: [RawDecodableMock] = [
            RawDecodableMock(),
            RawDecodableMock(),
            RawDecodableMock()
        ]
        let dtoDecodableMock = DTODecodableMock()
        
        var result: [DTODecodableMock]?
        var receivedError: Error?
        
        DTODecodableMock.stubbedFromResult = .success(dtoDecodableMock)
        
        // when
        
        do {
            result = try Array<DTODecodableMock>.from(dto: array)
        } catch {
            receivedError = error
        }
        
        // then
        
        let value = try XCTUnwrap(result)
        
        XCTAssertNil(receivedError)
        XCTAssertEqual(value.count, array.count)
        
        value.forEach {
            XCTAssertTrue($0 === dtoDecodableMock)
        }
    }
    
    func testToDTO_thenToDTOCalledInEachElement() throws {
        // given
        
        let array: [DTOEncodableMock<RawEncodableMock<Json>>] = [
            .init(),
            .init(),
            .init()
        ]
        
        array[0].stubbedToDTOResult = .success(.init())
        array[1].stubbedToDTOResult = .success(.init())
        array[2].stubbedToDTOResult = .success(.init())
        
        // when
        
       _ = try? array.toDTO()
        
        // then
        
        array.forEach {
            XCTAssertEqual($0.invokedToDTOCount, 1)
        }
    }
    
    func testToDTO_whenEncodingFailure_thenFailureReceived() throws {
        // given
        
        let array: [DTOEncodableMock<RawEncodableMock<Json>>] = [
            .init(),
            .init(),
            .init()
        ]
        
        array[0].stubbedToDTOResult = .success(.init())
        array[1].stubbedToDTOResult = .failure(MockError.secondError)
        array[2].stubbedToDTOResult = .success(.init())
        
        var result: [RawEncodableMock<Json>]?
        var receivedError: Error?
        
        // when
        
        do {
            result = try array.toDTO()
        } catch {
            receivedError = error
        }
        
        // then
        
        let error = try XCTUnwrap(receivedError as? MockError)
        
        XCTAssertNil(result)
        XCTAssertEqual(error, .secondError)
    }
    
    func testToDTO_whenEncodingSuccess_thenSuccessResultReceived() throws {
        // given
        
        let array: [DTOEncodableMock<RawEncodableMock<Json>>] = [
            .init(),
            .init(),
            .init()
        ]
        
        let expectedResult: [RawEncodableMock<Json>] = [
            .init(),
            .init(),
            .init()
        ]
        
        array[0].stubbedToDTOResult = .success(expectedResult[0])
        array[1].stubbedToDTOResult = .success(expectedResult[1])
        array[2].stubbedToDTOResult = .success(expectedResult[2])
        
        var result: [RawEncodableMock<Json>]?
        var receivedError: Error?
        
        // when
        
        do {
            result = try array.toDTO()
        } catch {
            receivedError = error
        }
        
        // then
        
        let value = try XCTUnwrap(result)
        
        XCTAssertNil(receivedError)
        XCTAssertEqual(value.count, array.count)
        
        value.enumerated().forEach {
            XCTAssertTrue($0.element === expectedResult[$0.offset])
        }
    }
}
