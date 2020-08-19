//
//  RequestCreatorNodeTests.swift
//  UnitTests
//
//  Created by Anastasiia Chechina on 18.08.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable import NodeKit

public class RequestCreatorNodeTests: XCTestCase {

    // MARK: - Nested

    enum Constants {
        static let headerKey = "TestHeader"
        static let headerValue = "testHeaderValue"
    }

    class StubNext: RequestProcessingLayerNode {

        var request: URLRequest! = nil

        @discardableResult
        public override func process(_ data: URLRequest) -> Observer<Json> {
            self.request = data
            return .emit(data: Json())
        }
    }

    class HeadersProvider: MetadataProvider {
        func metadata() -> [String : String] {
            return [Constants.headerKey: Constants.headerValue]
        }
    }

    // MARK: - Tests

    func testHeadersConvertionWork() {

        // Arrange

        let next = StubNext()
        let testedNode = RequestCreatorNode(next: next)
        let url = "http://test.com/usr"
        let provider = HeadersProvider()

        let request = TransportUrlRequest(method: .post,
                                          url: URL(string: url)!,
                                          headers: provider.metadata(),
                                          raw: Data())

        // Act

        let result = testedNode.process(request).log(nil)

        // Assert

        XCTAssertTrue(result.log?.description.contains(Constants.headerKey) != nil)
        XCTAssertTrue(result.log?.description.contains(Constants.headerValue) != nil)
    }

}
