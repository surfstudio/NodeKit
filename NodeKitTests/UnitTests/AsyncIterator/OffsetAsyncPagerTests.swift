//
//  OffsetAsyncPagerTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 04.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class OffsetAsyncPagerTests: XCTestCase {
    
    // MARK: - Tests
    
    func testNext_withArray_thenArrayWithNoEndReceived() async throws {
        // given

        let expectedArr = ["1", "2", "3", "4", "5"]
        
        let iterator = OffsetAsyncPager<[String]>(dataProvider: { index, offset in
            return .success((expectedArr, expectedArr.count))
        }, pageSize: 5)

        // when
        
        let result = await iterator.next()

        // then
        
        let unwrappedResult = try XCTUnwrap(result.value)

        XCTAssertEqual(unwrappedResult.data, expectedArr)
        XCTAssertFalse(unwrappedResult.end)
    }

    func testNext_withEmptySecondArray_thenEndReceivedOnlyLastTime() async throws {
        // given

        let expectedArr = ["1", "2", "3", "4", "5"]
        let iterator = OffsetAsyncPager<[String]>(dataProvider: { index, offset in
            if index >= 5 {
                return .success(([], 0))
            }

            return .success((expectedArr, expectedArr.count))
        }, pageSize: 5)
        
        var firstResult: Result<(data: [String], end: Bool), Error>?
        var secondResult: Result<(data: [String], end: Bool), Error>?

        // when

        firstResult = await iterator.next()
        secondResult = await iterator.next()

        // then
        
        let unwrapedFirstValue = try XCTUnwrap(firstResult?.value)
        let unwrappedSecondValue = try XCTUnwrap(secondResult?.value)
        
        XCTAssertEqual(unwrapedFirstValue.data, expectedArr)
        XCTAssertFalse(unwrapedFirstValue.end)
        XCTAssertEqual(unwrappedSecondValue.data, [])
        XCTAssertTrue(unwrappedSecondValue.end)
    }

    func testNext_withNonEmptySecondArray_thenEndReceivedOnlyLastTime() async throws {
        // given

        let expectedFirstArr = ["1", "2", "3", "4", "5"]
        let expectedSecondArr = ["1"]
        let iterator = OffsetAsyncPager<[String]>(dataProvider: { index, offset in
            if index >= 5 {
                return .success((expectedSecondArr, expectedSecondArr.count))
            }

            return .success((expectedFirstArr, expectedFirstArr.count))
        }, pageSize: 5)


        var firstResult: Result<(data: [String], end: Bool), Error>?
        var secondResult: Result<(data: [String], end: Bool), Error>?

        // when

        firstResult = await iterator.next()
        secondResult = await iterator.next()

        // then
        
        let unwrapedFirstValue = try XCTUnwrap(firstResult?.value)
        let unwrappedSecondValue = try XCTUnwrap(secondResult?.value)

        XCTAssertEqual(unwrapedFirstValue.data, expectedFirstArr)
        XCTAssertFalse(unwrapedFirstValue.end)
        XCTAssertEqual(unwrappedSecondValue.data, expectedSecondArr)
        XCTAssertTrue(unwrappedSecondValue.end)
    }

    func testNext_withError_thenErrorReceived() async throws {
        // given

        let expectedError = MockError.firstError
        let iterator = OffsetAsyncPager<[String]>(dataProvider: { index, offset in
            return .failure(expectedError)
        }, pageSize: 5)


        // when

        let result = await iterator.next()

        // then
        
        let error = try XCTUnwrap(result.error as? MockError)

        XCTAssertEqual(error, expectedError)
    }
    
    func testRenew_thenZeroIndexReceived() async throws {
        // given

        let expectedArr = ["1", "2", "3", "4", "5"]
        var indexes: [Int] = []
        
        let iterator = OffsetAsyncPager<[String]>(dataProvider: { index, offset in
            indexes.append(index)
            return .success((expectedArr, expectedArr.count))
        }, pageSize: 5)

        // when
        
        _ = await iterator.next()
        _ = await iterator.next()
        
        await iterator.renew()
        
        _ = await iterator.next()

        // then

        XCTAssertEqual(indexes, [0, 5, 0])
    }
    
    func testSaveState_thenIteratorStartFromSavedState() async throws {
        // given

        let expectedArr = ["1", "2", "3", "4", "5"]
        var indexes: [Int] = []
        var offsets: [Int] = []
        
        let iterator = OffsetAsyncPager<[String]>(dataProvider: { index, offset in
            indexes.append(index)
            offsets.append(offset)
            return .success((expectedArr, expectedArr.count))
        }, pageSize: 5)

        // when
        
        await iterator.saveState()
        
        _ = await iterator.next()
        _ = await iterator.next()
        
        await iterator.restoreState()
        
        let _ = await iterator.next()

        // then

        XCTAssertEqual(indexes, [0, 5, 0])
        XCTAssertEqual(offsets, [5, 5, 5])
    }
    
    func testSaveState_whenSaveTwoStates_thenIteratorStartFromSavedState() async throws {
        // given

        let expectedArr = ["1", "2", "3", "4", "5"]
        var indexes: [Int] = []
        var offsets: [Int] = []
        
        let iterator = OffsetAsyncPager<[String]>(dataProvider: { index, offset in
            indexes.append(index)
            offsets.append(offset)
            return .success((expectedArr, expectedArr.count))
        }, pageSize: 5)

        // when
        
        await iterator.saveState()
        
        _ = await iterator.next()
        
        await iterator.saveState()
        
        _ = await iterator.next()

        await iterator.restoreState()
        
        let _ = await iterator.next()
        
        await iterator.restoreState()
        
        let _ = await iterator.next()

        // then

        XCTAssertEqual(indexes, [0, 5, 5, 0])
        XCTAssertEqual(offsets, [5, 5, 5, 5])
    }
    
    func testClearState_thenSavedStateCleared() async throws {
        // given

        let expectedArr = ["1", "2", "3", "4", "5"]
        var indexes: [Int] = []
        var offsets: [Int] = []
        
        let iterator = OffsetAsyncPager<[String]>(dataProvider: { index, offset in
            indexes.append(index)
            offsets.append(offset)
            return .success((expectedArr, expectedArr.count))
        }, pageSize: 5)

        // when
        
        await iterator.saveState()
        
        _ = await iterator.next()
        _ = await iterator.next()
        
        await iterator.clearStates()
        await iterator.restoreState()
        
        _ = await iterator.next()

        // then

        XCTAssertEqual(indexes, [0, 5, 10])
        XCTAssertEqual(offsets, [5, 5, 5])
    }
}
