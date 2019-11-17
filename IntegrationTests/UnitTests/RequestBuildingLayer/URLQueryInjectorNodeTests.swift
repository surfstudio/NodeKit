import Foundation
import XCTest

@testable import NodeKit

public class URLQueryInjectorNodeTests: XCTestCase {

    // MARK: - Nested

    class StubNode: Node<TransportUrlRequest, TransportUrlRequest> {
        override func process(_ data: TransportUrlRequest) -> Observer<TransportUrlRequest> {
            return .emit(data: data)
        }
    }

    // MARK: - Tests

    func testDefaultNodeWorkSuccessForSimpleQuery() {

        // Arrange

        let request = TransportUrlRequest(method: .get,
                                          url: URL(string: "http://host.dom/path")!,
                                          headers: [:],
                                          raw: Json(),
                                          parametersEncoding: .json)

        let query: [String : Any] = ["name": "bob", "age": 23]

        let node = URLQueryInjectorNode(next: StubNode(), query: query)

        // Act

        var result: URL!

        node.process(request).onCompleted { result = $0.url }

        // Assert

        XCTAssertEqual(result.query, "name=bob&age=23")
    }

    func testDefaultNodeSaveUrlAndOnlyAddQuery() {

        // Arrange

        let request = TransportUrlRequest(method: .get,
                                          url: URL(string: "http://host.dom/path")!,
                                          headers: [:],
                                          raw: Json(),
                                          parametersEncoding: .json)

        let query: [String : Any] = ["name": "bob", "age": 23]

        let node = URLQueryInjectorNode(next: StubNode(), query: query)

        // Act

        var result: URL!

        node.process(request).onCompleted { result = $0.url }

        // Assert

        XCTAssertEqual(result.absoluteString, "http://host.dom/path?name=bob&age=23")
    }

    func testDefaultNodeMutateOnlyUrlParameter() {

        // Arrange

        let request = TransportUrlRequest(method: .get,
                                          url: URL(string: "http://host.dom/path")!,
                                          headers: [:],
                                          raw: Json(),
                                          parametersEncoding: .json)

        let query: [String : Any] = ["name": "bob", "age": 23]

        let node = URLQueryInjectorNode(next: StubNode(), query: query)

        // Act

        var result: TransportUrlRequest!

        node.process(request).onCompleted { result = $0 }

        // Assert

        XCTAssertEqual(request.method, result.method)
        XCTAssertEqual(request.headers, result.headers)
        XCTAssertEqual(request.parametersEncoding, result.parametersEncoding)

        XCTAssertNotEqual(request.url, result.url)
    }

    func testDefaultNodeWorkSuccessForArrayQuery() {

        // Arrange

        let request = TransportUrlRequest(method: .get,
                                          url: URL(string: "http://host.dom/path")!,
                                          headers: [:],
                                          raw: Json(),
                                          parametersEncoding: .json)

        let query: [String : Any] = ["arr": ["a", 23, false]]

        let node = URLQueryInjectorNode(next: StubNode(), query: query)

        // Act

        var result: URL!

        node.process(request).onCompleted { result = $0.url }

        // Assert

        XCTAssertEqual(result.query!.removingPercentEncoding, "arr[]=a&arr[]=23&arr[]=0")
    }

    func testDefaultNodeWorkSuccessForDictQuery() {

        // Arrange

        let request = TransportUrlRequest(method: .get,
                                          url: URL(string: "http://host.dom/path")!,
                                          headers: [:],
                                          raw: Json(),
                                          parametersEncoding: .json)

        let query: [String : Any] = ["dict": ["name": "bob", "age": 23]]

        let node = URLQueryInjectorNode(next: StubNode(), query: query)

        // Act

        var result: URL!

        node.process(request).onCompleted { result = $0.url }

        // Assert

        XCTAssertEqual(result.query!.removingPercentEncoding, "dict[name]=bob&dict[age]=23")
    }

    func testDefaultNodeWorkSuccessForDictAndArrQuery() {

        // Arrange

        let request = TransportUrlRequest(method: .get,
                                          url: URL(string: "http://host.dom/path")!,
                                          headers: [:],
                                          raw: Json(),
                                          parametersEncoding: .json)

        let query: [String : Any] = ["dict": ["name": "bob", "age": 23], "arr": ["a", 23, false]]

        let node = URLQueryInjectorNode(next: StubNode(), query: query)

        // Act

        var result: URL!

        node.process(request).onCompleted { result = $0.url }

        // Assert

        XCTAssertEqual(result.query!.removingPercentEncoding, "dict[name]=bob&dict[age]=23&arr[]=a&arr[]=23&arr[]=0")
    }

    func testDefaultNodeWorkSuccessFor2DArrQuery() {

        // Arrange

        let request = TransportUrlRequest(method: .get,
                                          url: URL(string: "http://host.dom/path")!,
                                          headers: [:],
                                          raw: Json(),
                                          parametersEncoding: .json)

        let query: [String : Any] = ["arr": ["a", 23, false, ["map"]]]

        let node = URLQueryInjectorNode(next: StubNode(), query: query)

        // Act

        var result: URL!

        node.process(request).onCompleted { result = $0.url }

        // Assert

        XCTAssertEqual(result.query!.removingPercentEncoding, "arr[]=a&arr[]=23&arr[]=0&arr[][]=map")
    }
}
