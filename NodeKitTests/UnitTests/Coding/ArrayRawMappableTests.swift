//
//  ArrayRawMappableTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class ArrayRawMappableTests: XCTestCase {
    
    // MARK: - Lifecycle
    
    override func tearDown() {
        super.tearDown()
        RawDecodableMock.flush()
    }
    
    // MARK: - Tests
    
    func testToRaw_thenToRawCalledInEachElement() {
        // given
        
        let sut: [RawEncodableMock<Json>] = [
            .init(),
            .init(),
            .init()
        ]
        
        sut.forEach {
            $0.stubbedToRawResult = .success([:])
        }
        
        // when
        
        _ = try? sut.toRaw()
        
        // then
        
        sut.forEach {
            XCTAssertEqual($0.invokedToRawCount, 1)
        }
    }
    
    func testToRaw_withConvertationFailure_thenFailureReceived() throws {
        // given
        
        let sut: [RawEncodableMock<Json>] = [
            .init(),
            .init(),
            .init()
        ]
        
        sut[0].stubbedToRawResult = .success([:])
        sut[1].stubbedToRawResult = .success([:])
        sut[2].stubbedToRawResult = .failure(MockError.firstError)
        
        var result: Json?
        var receivedError: Error?
        
        // when
        
        do {
            result = try sut.toRaw()
        } catch {
            receivedError = error
        }
        
        // then
        
        let error = try XCTUnwrap(receivedError as? MockError)
        
        XCTAssertNil(result)
        XCTAssertEqual(error, .firstError)
    }
    
    func testToRaw_withConvertationSuccess_thenSuccessReceived() throws {
        // given
        
        let sut: [RawEncodableMock<Json>] = [
            .init(),
            .init(),
            .init()
        ]
        
        let jsonArray = [
            ["TestKey1": "TestValue1"],
            ["TestKey2": "TestValue2"],
            ["TestKey3": "TestValue3"]
        ]
        
        sut[0].stubbedToRawResult = .success(jsonArray[0])
        sut[1].stubbedToRawResult = .success(jsonArray[1])
        sut[2].stubbedToRawResult = .success(jsonArray[2])
        
        var result: Json?
        var receivedError: Error?
        
        // when
        
        do {
            result = try sut.toRaw()
        } catch {
            receivedError = error
        }
        
        // then
        
        let value = try XCTUnwrap(result as? [String: [[String: String]]])
        
        XCTAssertNil(receivedError)
        XCTAssertEqual(value, [MappingUtils.arrayJsonKey: jsonArray])
    }
    
    func testFromRaw_whenRawIsEmpty_thenEmptyReceived() throws {
        // given
        
        var result: [RawDecodableMock]?
        var receivedError: Error?
        
        // when
        
        do {
            result = try [RawDecodableMock].from(raw: [:])
        } catch {
            receivedError = error
        }
        
        // then
        
        let value = try XCTUnwrap(result)
        
        XCTAssertTrue(value.isEmpty)
        XCTAssertNil(receivedError)
    }
    
    func testFromRaw_withoutArrayJsonKey_thenErrorReceived() throws {
        // given
        
        let expectedRaw = ["TestKey": "TestValue"]
        
        var result: [RawDecodableMock]?
        var receivedError: Error?
        
        // when
        
        do {
            result = try [RawDecodableMock].from(raw: expectedRaw)
        } catch {
            receivedError = error
        }
        
        // then
        
        let error = try XCTUnwrap(receivedError as? ErrorArrayJsonMappiong)
        
        XCTAssertNil(result)
        
        if case let .cantFindKeyInRaw(raw) = error {
            let raw = try XCTUnwrap(raw as? [String: String])
            XCTAssertEqual(expectedRaw, raw)
        } else {
            XCTFail("Не верный результат работы метода")
        }
    }
    
    func testFromRaw_withArrayJsonKey_andWithoutJsonArray_thenErrorReceived() throws {
        // given
        
        let expectedRaw = [MappingUtils.arrayJsonKey: "TestValue"]
        
        var result: [RawDecodableMock]?
        var receivedError: Error?
        
        // when
        
        do {
            result = try [RawDecodableMock].from(raw: expectedRaw)
        } catch {
            receivedError = error
        }
        
        // then
        
        let error = try XCTUnwrap(receivedError as? ErrorArrayJsonMappiong)
        
        XCTAssertNil(result)
        
        if case let .cantFindKeyInRaw(raw) = error {
            let raw = try XCTUnwrap(raw as? [String: String])
            XCTAssertEqual(expectedRaw, raw)
        } else {
            XCTFail("Не верный результат работы метода")
        }
    }
    
    func testFromRaw_withArrayJsonKey_andWithJsonArray_thenRawDecodableFromCalled() throws {
        // given
        
        let expectedArray = [
            ["TestKey1": "TestValue1"],
            ["TestKey2": "TestValue2"],
            ["TestKey3": "TestValue3"]
        ]
        RawDecodableMock.stubbedFromResult = .success(.init())
        
        // when
        
        _ = try? [RawDecodableMock].from(raw: [MappingUtils.arrayJsonKey: expectedArray])
        
        // then
        
        XCTAssertEqual(RawDecodableMock.invokedFromCount, expectedArray.count)
        
        try RawMappableMock.invokedFromParameterList.enumerated().forEach {
            let value = try XCTUnwrap($0.element as? [String: String])
            XCTAssertEqual(value, expectedArray[$0.offset])
        }
    }
    
    func testFromRaw_withConvertationFailure_thenFailureReceived() throws {
        // given
        
        let arr = [
            ["TestKey1": "TestValue1"],
            ["TestKey2": "TestValue2"],
            ["TestKey3": "TestValue3"]
        ]
        RawDecodableMock.stubbedFromResult = .failure(MockError.secondError)
        
        var result: [RawDecodableMock]?
        var receivedError: Error?
        
        // when
        
        do {
            result = try [RawDecodableMock].from(raw: [MappingUtils.arrayJsonKey: arr])
        } catch {
            receivedError = error
        }
        
        // then
        
        let error = try XCTUnwrap(receivedError as? MockError)
        
        XCTAssertNil(result)
        XCTAssertEqual(error, .secondError)
    }
    
    func testFromRaw_withConvertationSuccess_thenSuccessReceived() throws {
        // given
        
        let arr = [
            ["TestKey1": "TestValue1"],
            ["TestKey2": "TestValue2"],
            ["TestKey3": "TestValue3"]
        ]
        let rawDecodableMock = RawDecodableMock()
        
        RawDecodableMock.stubbedFromResult = .success(rawDecodableMock)
        
        var result: [RawDecodableMock]?
        var receivedError: Error?
        
        // when
        
        do {
            result = try [RawDecodableMock].from(raw: [MappingUtils.arrayJsonKey: arr])
        } catch {
            receivedError = error
        }
        
        // then
        
        let value = try XCTUnwrap(result)
        
        XCTAssertNil(receivedError)
        XCTAssertEqual(value.count, arr.count)
        value.forEach {
            XCTAssertTrue($0 === rawDecodableMock)
        }
    }
}
