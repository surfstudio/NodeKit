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

        let normalizedRes = result.query!.split(separator: "&").sorted()
        let normalizedExp = "age=23&name=bob".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
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

        let normalizedRes = result.query!.split(separator: "&").sorted()
        let normalizedExp = "age=23&name=bob".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)

        XCTAssertEqual(result.absoluteString.replacingOccurrences(of: result.query!, with: ""), "http://host.dom/path?")
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

        let normalizedRes = result.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "arr[]=a&arr[]=23&arr[]=0".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
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

        let normalizedRes = result.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "dict[age]=23&dict[name]=bob".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
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

        let normalizedRes = result.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "dict[age]=23&dict[name]=bob&arr[]=a&arr[]=23&arr[]=0".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
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

        let normalizedRes = result.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "arr[]=a&arr[]=23&arr[]=0&arr[][]=map".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }
}
