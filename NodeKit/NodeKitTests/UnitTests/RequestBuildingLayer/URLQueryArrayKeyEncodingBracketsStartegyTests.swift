import Foundation
import XCTest

@testable import NodeKit

public class URLQueryArrayKeyEncodingBracketsStartegyTests: XCTestCase {
    public func testBracketsStrategyWorkSuccess() {

        // Arrange

        let value = "array"
        let strategy = URLQueryArrayKeyEncodingBracketsStartegy.brackets

        // Act

        let result = strategy.encode(value: value)

        // Assert

        XCTAssertEqual(result, "\(value)[]")
    }

    public func testNoBracketsStrategyWorkSuccess() {

        // Arrange

        let value = "array"
        let strategy = URLQueryArrayKeyEncodingBracketsStartegy.noBrackets

        // Act

        let result = strategy.encode(value: value)

        // Assert

        XCTAssertEqual(result, "\(value)")
    }
}
