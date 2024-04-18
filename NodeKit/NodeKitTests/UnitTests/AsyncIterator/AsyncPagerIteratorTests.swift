//
//  AsyncPagerIteratorTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 04.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class AsyncPagerIteratorTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var pageSize: Int = 5
    private var dataProviderMock: AsyncPagerDataProviderMock<[String]>!
    
    // MARK: - Sut
    
    private var sut: AsyncPagerIterator<[String]>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        dataProviderMock = AsyncPagerDataProviderMock()
        sut = AsyncPagerIterator(dataProvider: dataProviderMock, pageSize: pageSize)
    }
    
    override func tearDown() {
        super.tearDown()
        dataProviderMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testNext_whenSuccess_thenDataProviderCalled() async throws {
        // given

        let expectedIndex = 0
        
        dataProviderMock.stubbedProvideResult = .success(.init(value: [], len: 1))

        // when
        
        await sut.next()

        // then
        
        let parameters = try XCTUnwrap(dataProviderMock.invokedProvideParameters)

        XCTAssertEqual(dataProviderMock.invokedProvideCount, 1)
        XCTAssertEqual(parameters.index, expectedIndex)
        XCTAssertEqual(parameters.pageSize, pageSize)
    }
    
    func testNext_whenCalledTwoTimes_withSuccess_thenDataProviderCalled() async throws {
        // given

        let expectedIndex = 0
        
        dataProviderMock.stubbedProvideResult = .success(.init(value: [], len: 5))

        // when
        
        await sut.next()
        await sut.next()

        // then
        
        let firstCallParameters = try XCTUnwrap(dataProviderMock.invokedProvideParametersList.safe(index: 0))
        let secondCallParameters = try XCTUnwrap(dataProviderMock.invokedProvideParametersList.safe(index: 1))

        XCTAssertEqual(dataProviderMock.invokedProvideCount, 2)
        XCTAssertEqual(firstCallParameters.index, expectedIndex)
        XCTAssertEqual(firstCallParameters.pageSize, pageSize)
        XCTAssertEqual(secondCallParameters.index, expectedIndex + pageSize)
        XCTAssertEqual(secondCallParameters.pageSize, pageSize)
    }
    
    func testNext_whenSuccess_thenSuccessReceived() async throws {
        // given

        let expectedArr = ["1", "2", "3", "4", "5"]

        dataProviderMock.stubbedProvideResult = .success(.init(value: expectedArr, len: expectedArr.count))

        // when
        
        let result = await sut.next()

        // then
        
        let unwrappedResult = try XCTUnwrap(result.value)

        XCTAssertEqual(unwrappedResult, expectedArr)
    }
    
    func testNext_whenFailure_thenFailureReceived() async throws {
        // given
        
        dataProviderMock.stubbedProvideResult = .failure(MockError.firstError)

        // when
        
        let result = await sut.next()

        // then
        
        let error = try XCTUnwrap(result.error as? MockError)

        XCTAssertEqual(error, .firstError)
    }
    
    func testHasNext_whenFullArrayReceived_thenHasNext() async throws {
        // given
        
        dataProviderMock.stubbedProvideResult = .success(.init(
            value: ["1", "2", "3", "4", "5"],
            len: 5
        ))

        // when
        
        await sut.next()
        let hasNext = await sut.hasNext()

        // then
        
        XCTAssertTrue(hasNext)
    }
    
    func testHasNext_whenEmptyArrayReceived_thenHasNotNext() async throws {
        // given

        dataProviderMock.stubbedProvideResult = .success(.init(
            value: [],
            len: 0
        ))

        // when
        
        await sut.next()
        let hasNext = await sut.hasNext()

        // then
        
        XCTAssertFalse(hasNext)
    }
    
    func testHasNext_whenArrayWithSizeLessThanPageSizeReceived_thenHasNotNext() async throws {
        // given

        dataProviderMock.stubbedProvideResult = .success(.init(
            value: [],
            len: 3
        ))

        // when
        
        await sut.next()
        let hasNext = await sut.hasNext()

        // then
        
        XCTAssertFalse(hasNext)
    }
    
    func testHasNext_whenFailure_thenHasNotNext() async throws {
        // given

        dataProviderMock.stubbedProvideResult = .failure(MockError.firstError)

        // when
        
        await sut.next()
        let hasNext = await sut.hasNext()

        // then
        
        XCTAssertFalse(hasNext)
    }
    
    func testRenew_thenZeroIndexReceived() async throws {
        // given

        let expectedArr = ["1", "2", "3", "4", "5"]
        
        dataProviderMock.stubbedProvideResult = .success(.init(value: expectedArr, len: expectedArr.count))

        // when
        
        await sut.next()
        await sut.next()
        await sut.renew()
        await sut.next()

        // then
        
        let indexes = dataProviderMock.invokedProvideParametersList.map { $0.index }
        let pageSizes = dataProviderMock.invokedProvideParametersList.map { $0.pageSize }

        XCTAssertEqual(indexes, [0, 5, 0])
        XCTAssertEqual(pageSizes, [5, 5, 5])
    }
    
    func testSaveState_thenIteratorStartFromSavedState() async throws {
        // given

        let expectedArr = ["1", "2", "3", "4", "5"]
        
        dataProviderMock.stubbedProvideResult = .success(.init(value: expectedArr, len: expectedArr.count))

        // when
        
        await sut.saveState()
        await sut.next()
        await sut.next()
        await sut.restoreState()
        await sut.next()

        // then
        
        let indexes = dataProviderMock.invokedProvideParametersList.map { $0.index }
        let pageSizes = dataProviderMock.invokedProvideParametersList.map { $0.pageSize }

        XCTAssertEqual(indexes, [0, 5, 0])
        XCTAssertEqual(pageSizes, [5, 5, 5])
    }
    
    func testSaveState_whenSaveTwoStates_thenIteratorStartFromSavedState() async throws {
        // given

        let expectedArr = ["1", "2", "3", "4", "5"]
        
        dataProviderMock.stubbedProvideResult = .success(.init(value: expectedArr, len: expectedArr.count))

        // when
        
        await sut.saveState()
        await sut.next()
        await sut.saveState()
        await sut.next()
        await sut.restoreState()
        await sut.next()
        await sut.restoreState()
        await sut.next()

        // then
        
        let indexes = dataProviderMock.invokedProvideParametersList.map { $0.index }
        let pageSizes = dataProviderMock.invokedProvideParametersList.map { $0.pageSize }

        XCTAssertEqual(indexes, [0, 5, 5, 0])
        XCTAssertEqual(pageSizes, [5, 5, 5, 5])
    }
    
    func testClearState_thenSavedStateCleared() async throws {
        // given

        let expectedArr = ["1", "2", "3", "4", "5"]
        
        dataProviderMock.stubbedProvideResult = .success(.init(value: expectedArr, len: expectedArr.count))

        // when
        
        await sut.saveState()
        await sut.next()
        await sut.next()
        await sut.clearStates()
        await sut.restoreState()
        await sut.next()

        // then
        
        let indexes = dataProviderMock.invokedProvideParametersList.map { $0.index }
        let pageSizes = dataProviderMock.invokedProvideParametersList.map { $0.pageSize }

        XCTAssertEqual(indexes, [0, 5, 10])
        XCTAssertEqual(pageSizes, [5, 5, 5])
    }
}
