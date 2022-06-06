//
//  OffsetAsyncPagerTests.swift
//  IntegrationTests
//

import Foundation
import XCTest

@testable import NodeKit

final class OffsetAsyncPagerTests: XCTestCase {
    func testOffsetIteratorReturnsValue() {
        // given

        let data = ["1", "2", "3", "4", "5"]
        let iterator = OffsetAsyncPager<[String]>(dataPrivider: { index, offset in
            return .emit(data: (data, data.count))
        }, pageSize: 5)

        var accept = [String]()

        // when

        iterator.next().onCompleted { accept = $0 }

        // then

        XCTAssertEqual(accept, data)
    }

    func testOffsetIteratorOnEndCalledInCaseOfZeroOutput() {
        // given

        let arr = ["1", "2", "3", "4", "5"]
        let iterator = OffsetAsyncPager<[String]>(dataPrivider: { index, offset in

            if index >= 5 {
                return .emit(data: ([], 0))
            }

            return .emit(data: (arr, arr.count))
        }, pageSize: 5)


        var wasEnded = false
        var completedCount = 0

        // when

        iterator.onEnd { wasEnded = true }

        for _ in 0...1 {
            iterator.next().onCompleted { _ in completedCount += 1 }
        }

        // then

        XCTAssertTrue(wasEnded)
        XCTAssertEqual(completedCount, 2)
    }

    func testOffsetIteratorOnEndCalledInCaseOfNonZeroOutput() {
        // given

        let arr = ["1", "2", "3", "4", "5"]
        let last = ["1"]
        let iterator = OffsetAsyncPager<[String]>(dataPrivider: { index, offset in

            if index >= 5 {
                return .emit(data: (last, last.count))
            }

            return .emit(data: (arr, arr.count))
        }, pageSize: 5)


        var wasEnded = false
        var lastItem = [String]()

        // when

        iterator.onEnd { wasEnded = true }

        for _ in 0...1 {
            iterator.next().onCompleted { lastItem = $0 }
        }

        // then

        XCTAssertTrue(wasEnded)
        XCTAssertEqual(lastItem, last)
    }

    func testOffsetIteratorOnErrorReturnsDataProviderError() {
        // given

        let err = NSError(domain: "test.dom", code: 1000, userInfo: nil)
        let iterator = OffsetAsyncPager<[String]>(dataPrivider: { index, offset in
            return .emit(error: err)
        }, pageSize: 5)

        var recived: NSError!

        // when

        iterator.next().onError { recived = $0 as NSError }

        // then

        XCTAssertTrue(recived === err)
    }

    func testOffsetIteratorInCaseIfEmptyDataProviderReturnsErr() {
        // given

        let iterator = OffsetAsyncPager<[String]>(dataPrivider: nil, pageSize: 5)

        var recived: PagingError?

        // when

        iterator.next().onError { recived = $0 as? PagingError }

        // then

        XCTAssertEqual(recived!, PagingError.dataProviderNotSet)
    }
}
