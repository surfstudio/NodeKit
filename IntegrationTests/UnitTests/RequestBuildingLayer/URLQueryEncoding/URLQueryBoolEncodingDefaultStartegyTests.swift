import Foundation
import XCTest

@testable import NodeKit

public class URLQueryBoolEncodingDefaultStartegyTests: XCTestCase {

    public func testAsIntStrategyWorkForFalse() {

        // Arrange

        let value = false
        let strategy = URLQueryBoolEncodingDefaultStartegy.asInt

        // Act

        let result = strategy.encode(value: value)

        // Assert

        XCTAssertEqual(result, "0")
    }

    public func testAsIntStrategyWorkForTrue() {

        // Arrange

        let value = true
        let strategy = URLQueryBoolEncodingDefaultStartegy.asInt

        // Act

        let result = strategy.encode(value: value)

        // Assert

        XCTAssertEqual(result, "1")
    }

    public func testAsBoolStrategyWorkForFalse() {

        // Arrange

        let value = false
        let strategy = URLQueryBoolEncodingDefaultStartegy.asBool

        // Act

        let result = strategy.encode(value: value)

        // Assert

        XCTAssertEqual(result, "false")
    }

    public func testAsBoolStrategyWorkForTrue() {

        // Arrange

        let value = true
        let strategy = URLQueryBoolEncodingDefaultStartegy.asBool

        // Act

        let result = strategy.encode(value: value)

        // Assert

        XCTAssertEqual(result, "true")
    }
}
