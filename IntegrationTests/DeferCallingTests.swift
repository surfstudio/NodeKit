//
//  DeferCallingTests.swift
//  IntegrationTests
//
//  Created by Anton Dryakhlykh on 14.02.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

public class DeferCallingTests: XCTestCase {

    // MARK: - Tests

    public func testDeferCallingNow() {

        // given

        let dataContext = Context<Void>()
        var dataResult = [String]()
        let errorContext = Context<Void>()
        var errorResult = [String]()

        // when

        dataContext.emit(data: ())
        errorContext.emit(error: ResponseHttpErrorProcessorNodeError.notFound)

        dataContext
            .onCompleted {
                dataResult.append("data")
            }.onError { error in
                dataResult.append("error")
            }.defer {
                dataResult.append("defer")
            }

        errorContext
            .onCompleted {
                errorResult.append("data")
            }.onError { error in
                errorResult.append("error")
            }.defer {
                errorResult.append("defer")
            }

        // then

        XCTAssertEqual(dataResult, ["data", "defer"])
        XCTAssertEqual(errorResult, ["error", "defer"])
    }

    public func testDeferCallingAfterTime() {

        // given

        let dataContext = Context<Void>()
        var dataResult = [String]()
        let errorContext = Context<Void>()
        var errorResult = [String]()

        let expectation = self.expectation(description: #function)

        // when

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            dataContext.emit(data: ())
            errorContext.emit(error: ResponseHttpErrorProcessorNodeError.notFound)
            expectation.fulfill()
        }

        dataContext
            .onCompleted {
                dataResult.append("data")
            }.onError { error in
                dataResult.append("error")
            }.defer {
                dataResult.append("defer")
            }

        errorContext
            .onCompleted {
                errorResult.append("data")
            }.onError { error in
                errorResult.append("error")
            }.defer {
                errorResult.append("defer")
            }

        waitForExpectations(timeout: 5.0)

        // then

        XCTAssertEqual(dataResult, ["data", "defer"])
        XCTAssertEqual(errorResult, ["error", "defer"])
    }
}
