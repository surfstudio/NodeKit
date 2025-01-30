//
//  LoggingContextTests.swift
//  NodeKitTests
//
//  Created by frolov on 19.03.2024.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

import XCTest

final class LoggingContextTests: XCTestCase {

    // MARK: - Sut

    private var sut: LoggingContext!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        sut = LoggingContext()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    // MARK: - Tests

    func testLog_whenNothingAppending_thenResultIsNil() async {
        // when

        let result = await sut.log

        // then

        XCTAssertNil(result)
    }

    func testLog_whenOneItemAppending_thenResultIsAppendedItem() async throws {
        // given

        let testLog = LogChain("Test message", id: "Test id", logType: .failure)

        // when

        await sut.add(testLog)

        let log = await sut.log
        let result = try XCTUnwrap(log as? LogChain)

        // then

        XCTAssertEqual(result, testLog)
    }

    func testLog_whenTwoItemsAppending_thenResultIsFirstItemAndNextIsSecondItem() async throws {
        // given

        let firstLog = LogChain("Test first message", id: "Test first id", logType: .failure)
        let secondLog = LogChain("Test second message", id: "Test second id", logType: .info)

        var expectedLog = firstLog
        expectedLog.next = secondLog

        // when

        await sut.add(firstLog)
        await sut.add(secondLog)

        let log = await sut.log
        let result = try XCTUnwrap(log as? LogChain)
        let resultNext = try XCTUnwrap(result.next as? LogChain)

        // then

        XCTAssertEqual(result, expectedLog)
        XCTAssertEqual(resultNext, secondLog)
        XCTAssertNil(resultNext.next)
    }

    /// Элементы в лог вставляются не в конец, а в начало списка, при этом первый лог не меняется.
    /// При добавлении Log3 в список Log1 -> Log2, получается новый список Log1 -> Log3 -> Log2
    func testLog_whenThreeItemsAppending_thenResultIsFirstItemAndNextIsTree() async throws {
        // given

        let firstLog = LogChain("Test first message", id: "Test first id", logType: .info)
        let secondLog = LogChain("Test second message", id: "Test second id", logType: .failure)
        let thirdLog = LogChain("Test third message", id: "Test third id", logType: .info)

        var expectedLog = firstLog
        var expectedThirdLog = thirdLog

        expectedThirdLog.next = secondLog
        expectedLog.next = expectedThirdLog

        // when

        await sut.add(firstLog)
        await sut.add(secondLog)
        await sut.add(thirdLog)

        let log = await sut.log
        let result = try XCTUnwrap((log) as? LogChain)
        let firstNextResult = try XCTUnwrap(result.next as? LogChain)
        let secondNextResult = try XCTUnwrap(firstNextResult.next as? LogChain)

        // then

        XCTAssertEqual(result, expectedLog)
        XCTAssertEqual(firstNextResult, expectedThirdLog)
        XCTAssertEqual(secondNextResult, secondLog)
        XCTAssertNil(secondNextResult.next)
    }
    
    func testLog_whenFourItemsAppending_thenResultIsFirstItemAndNextIsTree() async throws {
        // given

        let firstLog = LogChain("Test first message", id: "Test first id", logType: .failure)
        let secondLog = LogChain("Test second message", id: "Test second id", logType: .failure)
        let thirdLog = LogChain("Test third message", id: "Test third id", logType: .info)
        let fourthLog = LogChain("Test fourth message", id: "Test fourth id", logType: .info)

        var expectedLog = firstLog
        var expectedFourthLog = fourthLog
        var expectedThirdLog = thirdLog

        expectedThirdLog.next = secondLog
        expectedFourthLog.next = expectedThirdLog
        expectedLog.next = expectedFourthLog

        // when

        await sut.add(firstLog)
        await sut.add(secondLog)
        await sut.add(thirdLog)
        await sut.add(fourthLog)

        let log = await sut.log
        let result = try XCTUnwrap(log as? LogChain)
        let firstNextResult = try XCTUnwrap(result.next as? LogChain)
        let secondNextResult = try XCTUnwrap(firstNextResult.next as? LogChain)
        let thirdNextResult = try XCTUnwrap(secondNextResult.next as? LogChain)

        // then

        XCTAssertEqual(result, expectedLog)
        XCTAssertEqual(firstNextResult, expectedFourthLog)
        XCTAssertEqual(secondNextResult, expectedThirdLog)
        XCTAssertEqual(thirdNextResult, secondLog)
        XCTAssertNil(thirdNextResult.next)
    }

    func testLog_withLogSubscription() async throws {
        // given

        let firstLog = LogChain("Test first message", id: "Test first id", logType: .failure)
        let secondLog = LogChain("Test second message", id: "Test second id", logType: .failure)
        let thirdLog = LogChain("Test third message", id: "Test third id", logType: .info)
        let fourthLog = LogChain("Test fourth message", id: "Test fourth id", logType: .info)

        var logs: [[Log]] = []

        await sut.subscribe {
            logs.append($0)
        }

        // when

        await sut.add(firstLog)
        await sut.add(secondLog)
        await sut.add(thirdLog)
        await sut.add(fourthLog)
        await sut.complete()

        // then

        let receivedLogs = try logs.flatMap {
            try XCTUnwrap($0 as? [LogChain])
        }
        XCTAssertEqual(receivedLogs, [firstLog, fourthLog, thirdLog, secondLog])
    }

    func testLog_withLogSubscription_whenSubscibeAfterComplete() async throws {
        // given

        let firstLog = LogChain("Test first message", id: "Test first id", logType: .failure)
        let secondLog = LogChain("Test second message", id: "Test second id", logType: .failure)
        let thirdLog = LogChain("Test third message", id: "Test third id", logType: .info)
        let fourthLog = LogChain("Test fourth message", id: "Test fourth id", logType: .info)

        var logs: [[Log]] = []

        // when

        await sut.add(firstLog)
        await sut.add(secondLog)
        await sut.add(thirdLog)
        await sut.add(fourthLog)
        await sut.complete()

        await sut.subscribe {
            logs.append($0)
        }

        // then

        let receivedLogs = try logs.flatMap {
            try XCTUnwrap($0 as? [LogChain])
        }
        XCTAssertEqual(receivedLogs, [firstLog, fourthLog, thirdLog, secondLog])
    }

    func testLog_withLogSubscription_whenLogIsNil() async {
        // given

        var logs: [[Log]] = []

        await sut.subscribe {
            logs.append($0)
        }

        // when

        await sut.add(nil)
        await sut.add(nil)
        await sut.add(nil)
        await sut.add(nil)
        await sut.complete()

        // then

        XCTAssert(logs.isEmpty)
    }

}
