//
//  MultipartModelTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class MultipartModelTests: XCTestCase {
    
    // MARK: - Lifecycle
    
    override func tearDown() {
        super.tearDown()
        DTOConvertibleMock.flush()
        RawMappableMock.flush()
    }
    
    // MARK: - Tests
    
    func testFromDTO_thenPayloadFromDTOCalled() throws {
        // given

        let dto = MultipartModel<RawMappableMock>(payloadModel: .init())
        
        DTOConvertibleMock.stubbedFromResult = .success(.init())
        
        // when
        
        _ = try? MultipartModel<DTOConvertibleMock>.from(dto: dto)
        
        // then
        
        let input = try XCTUnwrap(DTOConvertibleMock.invokedFromParameter)
        
        XCTAssertEqual(DTOConvertibleMock.invokedFromCount, 1)
        XCTAssertTrue(input === dto.payloadModel)
    }
    
    func testFromDTO_whenDTOConvertionFailure_thenFailureReceived() throws {
        // given

        let dto = MultipartModel<RawMappableMock>(payloadModel: .init())
        
        DTOConvertibleMock.stubbedFromResult = .failure(MockError.firstError)
        
        var result: MultipartModel<DTOConvertibleMock>?
        var receivedError: Error?
        
        // when
        
        do {
            result = try MultipartModel<DTOConvertibleMock>.from(dto: dto)
        } catch {
            receivedError = error
        }
        
        // then
        
        let error = try XCTUnwrap(receivedError as? MockError)
        
        XCTAssertNil(result)
        XCTAssertEqual(error, .firstError)
    }
    
    func testFromDTO_whenDTOConvertionSuccess_thenSuccessReceived() throws {
        // given

        let expectedResult = DTOConvertibleMock()
        let dto = MultipartModel<RawMappableMock>(payloadModel: .init())
        
        DTOConvertibleMock.stubbedFromResult = .success(expectedResult)
        
        var result: MultipartModel<DTOConvertibleMock>?
        var receivedError: Error?
        
        // when
        
        do {
            result = try MultipartModel<DTOConvertibleMock>.from(dto: dto)
        } catch {
            receivedError = error
        }
        
        // then
        
        let value = try XCTUnwrap(result)
        
        XCTAssertNil(receivedError)
        XCTAssertTrue(value.payloadModel === expectedResult)
    }
    
    func testToDTO_thenPayloadToDTOCalled() {
        // given

        let dtoConvertibelMock = DTOConvertibleMock()
        let sut = MultipartModel<DTOConvertibleMock>(payloadModel: dtoConvertibelMock)
        
        dtoConvertibelMock.stubbedToDTOResult = .success(.init())
        
        // when
        
        _ = try? sut.toDTO()
        
        // then
        
        XCTAssertEqual(dtoConvertibelMock.invokedToDTOCount, 1)
    }
    
    func testToDTO_whenDTOConvertionFailure_thenFailureReceived() throws {
        // given

        let dtoConvertibelMock = DTOConvertibleMock()
        let sut = MultipartModel<DTOConvertibleMock>(payloadModel: dtoConvertibelMock)
        
        dtoConvertibelMock.stubbedToDTOResult = .failure(MockError.secondError)
        
        var result: MultipartModel<DTOConvertibleMock.DTO>?
        var receivedError: Error?
        
        // when
        
        do {
            result = try sut.toDTO()
        } catch {
            receivedError = error
        }
        
        // then
        
        let error = try XCTUnwrap(receivedError as? MockError)
        
        XCTAssertNil(result)
        XCTAssertEqual(error, .secondError)
    }
    
    func testToDTO_whenDTOConvertionSuccess_thenSuccessReceived() throws {
        // given

        let dtoConvertibelMock = DTOConvertibleMock()
        let rawMappableMock = RawMappableMock()
        let sut = MultipartModel<DTOConvertibleMock>(payloadModel: dtoConvertibelMock)
        
        dtoConvertibelMock.stubbedToDTOResult = .success(rawMappableMock)
        
        var result: MultipartModel<DTOConvertibleMock.DTO>?
        var receivedError: Error?
        
        // when
        
        do {
            result = try sut.toDTO()
        } catch {
            receivedError = error
        }
        
        // then
        
        let value = try XCTUnwrap(result)
        
        XCTAssertNil(receivedError)
        XCTAssertTrue(value.payloadModel === rawMappableMock)
    }
    
    func testToRaw_thenRawMappableToRawCalled() {
        // given
        
        let rawMapableMock = RawMappableMock()
        let sut = MultipartModel<RawMappableMock>(payloadModel: rawMapableMock)
        
        rawMapableMock.stubbedToRawResult = .success([:])
        
        // when
        
        _ = try? sut.toRaw()
        
        // then
        
        XCTAssertEqual(rawMapableMock.invokedToRawCount, 1)
    }
    
    func testToRaw_withToRawConvertationFailure_thenFailureReceived() throws {
        // given
        
        let rawMapableMock = RawMappableMock()
        let sut = MultipartModel<RawMappableMock>(payloadModel: rawMapableMock)
        
        rawMapableMock.stubbedToRawResult = .failure(MockError.thirdError)
        
        var result: MultipartModel<RawMappableMock.Raw>?
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
        XCTAssertEqual(error, .thirdError)
    }
    
    func testToRaw_withToRawConvertationSuccess_thenSuccessReceived() throws {
        // given
        
        let rawMapableMock = RawMappableMock()
        let expectedJson = ["TestKey": "TestValue"]
        let sut = MultipartModel<RawMappableMock>(payloadModel: rawMapableMock)
        
        rawMapableMock.stubbedToRawResult = .success(expectedJson)
        
        var result: MultipartModel<RawMappableMock.Raw>?
        var receivedError: Error?
        
        // when
        
        do {
            result = try sut.toRaw()
        } catch {
            receivedError = error
        }
        
        // then
        
        let value = try XCTUnwrap(result?.payloadModel as? [String: String])
        
        XCTAssertNil(receivedError)
        XCTAssertEqual(value, expectedJson)
    }
    
    func testFromRaw_thenRawMappableFromRawCalled() throws {
        // given
        
        let expectedJson = ["TestKey": "TestValue"]
        let raw = MultipartModel<Json>(payloadModel: expectedJson)
        
        RawMappableMock.stubbedFromResult = .success(.init())
        
        // when
        
        _ = try? MultipartModel<RawMappableMock>.from(raw: raw)
        
        // then
        
        let input = try XCTUnwrap(RawMappableMock.invokedFromParameter as? [String: String])
        
        XCTAssertEqual(RawMappableMock.invokedFromCount, 1)
        XCTAssertEqual(input, expectedJson)
    }
    
    func testFromRaw_withFromRawConvertationFailure_thenFailureReceived() throws {
        // given
        
        let raw = MultipartModel<Json>(payloadModel: [:])
        
        RawMappableMock.stubbedFromResult = .failure(MockError.firstError)
        
        var result: MultipartModel<RawMappableMock>?
        var receivedError: Error?
        
        // when
        
        do {
            result = try MultipartModel<RawMappableMock>.from(raw: raw)
        } catch {
            receivedError = error
        }
        
        // then
        
        let error = try XCTUnwrap(receivedError as? MockError)
        
        XCTAssertNil(result)
        XCTAssertEqual(error, .firstError)
    }
    
    func testFromRaw_withFromRawConvertationSuccess_thenSuccessReceived() throws {
        // given
        
        let raw = MultipartModel<Json>(payloadModel: [:])
        let rawMapableMock = RawMappableMock()
        
        RawMappableMock.stubbedFromResult = .success(rawMapableMock)
        
        var result: MultipartModel<RawMappableMock>?
        var receivedError: Error?
        
        // when
        
        do {
            result = try MultipartModel<RawMappableMock>.from(raw: raw)
        } catch {
            receivedError = error
        }
        
        // then
        
        let value = try XCTUnwrap(result?.payloadModel)
        
        XCTAssertNil(receivedError)
        XCTAssertTrue(value === rawMapableMock)
    }
}
