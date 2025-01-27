//
//  LogableTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

import XCTest

final class LogableTests: XCTestCase {
    
    // MARK: - Tests
    
    func testFlatMap_thenCorrectResultReceived() throws {
        // given
        
        var firstLog = LogChain("First message", id: "1", logType: .info, delimeter: "/", order: 0)
        var secondLog = LogChain("Second message", id: "1", logType: .failure, delimeter: "/", order: 0)
        let thirdLog = LogChain("Third message", id: "1", logType: .info, delimeter: "/", order: 0)

        secondLog.next = thirdLog
        firstLog.next = secondLog
        
        // when
        
        let result = firstLog.flatMap()
        
        // then
        
        let firstResult = try XCTUnwrap(result.safe(index: 0))
        let secondResult = try XCTUnwrap(result.safe(index: 1))
        let thirdResult = try XCTUnwrap(result.safe(index: 2))
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(firstResult.description, "/First message/")
        XCTAssertEqual(secondResult.description, "/Second message/")
        XCTAssertEqual(thirdResult.description, "/Third message/")
    }
    
}
