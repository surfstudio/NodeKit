import Foundation
import XCTest

@testable import NodeKit

public class URLQueryDictionaryKeyEncodingDefaultStrategyTests: XCTestCase {
    public func testStrategyWorkSuccess() {

        // Arrange

        let queryKey = "dict"
        let dictKey = "name"
        let strategy = URLQueryDictionaryKeyEncodingDefaultStrategy()

        // Act

        let result = strategy.encode(queryItemName: queryKey, dictionaryKey: dictKey)

        // Assert

        XCTAssertEqual(result, "\(queryKey)[\(dictKey)]")
    }
}
