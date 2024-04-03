//
//  NodeResultTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 03.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class NodeResultTests: XCTestCase {
    
    // MARK: - Tests
    
    func testAsyncFlatMap_whenSucess_thenSucessReceived() async {
        // given
        
        let sut: NodeResult<Int> = .success(15)
        let expectedResult: NodeResult<Int> = .success(21)
        
        // when
        
        let result = await sut.asyncFlatMap { value in
            return expectedResult
        }
        
        // then
        
        XCTAssertEqual(result.castToMockError(), expectedResult.castToMockError())
    }
    
    func testAsyncFlatMap_whenSucess_andTrasformToError_thenErrorReceived() async {
        // given
        
        let sut: NodeResult<Int> = .success(15)
        let expectedResult: NodeResult<Int> = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.asyncFlatMap { value in
            return expectedResult
        }
        
        // then
        
        XCTAssertEqual(result.castToMockError(), expectedResult.castToMockError())
    }
    
    func testAsyncFlatMap_whenFailure_thenTransformIgnored() async {
        // given
        
        let sut: NodeResult<Int> = .failure(MockError.thirdError)
        
        // when
        
        let result = await sut.asyncFlatMap { value in
            return .success(21)
        }
        
        // then
        
        XCTAssertEqual(result.castToMockError(), sut.castToMockError())
    }
    
    func testAsyncFlatMapError_whenFailure_thenFailureReceived() async {
        // given
        
        let sut: NodeResult<Int> = .failure(MockError.secondError)
        let expectedResult: NodeResult<Int> = .failure(MockError.firstError)
        
        // when
        
        let result = await sut.asyncFlatMapError { value in
            return expectedResult
        }
        
        // then
        
        XCTAssertEqual(result.castToMockError(), expectedResult.castToMockError())
    }
    
    func testAsyncFlatMapError_whenFailure_andTransformToSuccess_thenSuccessReceived() async {
        // given
        
        let sut: NodeResult<Int> = .failure(MockError.secondError)
        let expectedResult: NodeResult<Int> = .success(121)
        
        // when
        
        let result = await sut.asyncFlatMapError { value in
            return expectedResult
        }
        
        // then
        
        XCTAssertEqual(result.castToMockError(), expectedResult.castToMockError())
    }
    
    func testAsyncFlatMapError_whenSuccess_thenTransformIgnored() async {
        // given
        
        let sut: NodeResult<Int> = .success(156)
        
        // when
        
        let result = await sut.asyncFlatMapError { value in
            return .failure(MockError.secondError)
        }
        
        // then
        
        XCTAssertEqual(result.castToMockError(), sut.castToMockError())
    }
    
    func testMap_whenSucess_thenNewValueReceived() {
        // given
        
        let sut: NodeResult<Int> = .success(15)
        let expectedResult = 200
        
        var transform = { (value: Int) throws -> Int in
            return expectedResult
        }
        
        // when
        
        let result = try? sut.map(transform)
        
        // then
        
        XCTAssertEqual(result?.castToMockError(), .success(expectedResult))
    }
    
    func testMap_whenSucess_andTrasformThrowsError_thenErrorReceived() throws {
        // given
        
        let sut: NodeResult<Int> = .success(15)
        let expectedResult = MockError.secondError
        
        var transform = { (value: Int) throws -> Int in
            throw expectedResult
        }
        
        var receivedError: Error?

        // when
        
        do {
            _ = try sut.map(transform)
        } catch {
            receivedError = error
        }
        
        // then
        
        let custedError = try XCTUnwrap(receivedError as? MockError)
        
        XCTAssertEqual(custedError, expectedResult)
    }
    
    func testMap_whenFailure_thenTransformIgnored() async {
        // given
        
        let sut: NodeResult<Int> = .failure(MockError.thirdError)
        
        var transform = { (value: Int) throws -> Int in
            return 221
        }
        
        // when
        
        let result = try? sut.map(transform)
        
        // then
        
        XCTAssertEqual(result?.castToMockError(), sut.castToMockError())
    }
    
    func testWithMappedExceptions_withSuccessValue_thenSuccessReceived() async {
        // given
        
        let expectedResult: NodeResult<Int> = .success(91)
        
        // then
        
        let result = await NodeResult<Int>.withMappedExceptions {
            return expectedResult
        }
        
        // then
        
        XCTAssertEqual(result.castToMockError(), expectedResult.castToMockError())
    }
    
    func testWithMappedExceptions_withFailureValue_thenFailureReceived() async {
        // given
        
        let expectedResult: NodeResult<Int> = .failure(MockError.firstError)
        // then
        
        let result = await NodeResult<Int>.withMappedExceptions {
            return expectedResult
        }
        
        // then
        
        XCTAssertEqual(result.castToMockError(), expectedResult.castToMockError())
    }
    
    func testWithMappedExceptions_withErrorThrows_thenFailureReceived() async {
        // given
        
        let expectedError = MockError.firstError
        
        var function = { () throws -> NodeResult<Int> in
            throw expectedError
        }
        
        // then
        
        let result = await NodeResult<Int>.withMappedExceptions(nil, function)
        
        // then
        
        XCTAssertEqual(result.castToMockError(), .failure(expectedError))
    }
    
    func testWithMappedExceptions_withErrorThrows_andCustomError_thenFailureReceived() async {
        // given
        
        let expectedError = MockError.thirdError
        
        var function = { () throws -> NodeResult<Int> in
            throw MockError.secondError
        }
        
        // then
        
        let result = await NodeResult<Int>.withMappedExceptions(expectedError, function)
        
        // then
        
        XCTAssertEqual(result.castToMockError(), .failure(expectedError))
    }
    
    func testValue_whenSuccess_thenValueReceived() {
        // given
        
        let expectedResult = 156
        let sut: NodeResult<Int> = .success(expectedResult)
        
        // when
        
        let result = sut.value
        
        // then
        
        XCTAssertEqual(result, expectedResult)
    }
    
    func testValue_whenFailure_thenNilReceived() {
        // given
        
        let sut: NodeResult<Int> = .failure(MockError.secondError)
        
        // when
        
        let result = sut.value
        
        // then
        
        XCTAssertNil(result)
    }
    
    func testError_whenFailure_thenErrorReceived() {
        // given
        
        let expectedError = MockError.secondError
        let sut: NodeResult<Int> = .failure(expectedError)
        
        // when
        
        let result = sut.error as? MockError
        
        // then
        
        XCTAssertEqual(result, expectedError)
    }
    
    func testError_whenSuccess_thenNilReceived() {
        // given
        
        let sut: NodeResult<Int> = .success(201)
        
        // when
        
        let result = sut.error
        
        // then
        
        XCTAssertNil(result)
    }
}
