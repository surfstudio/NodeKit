import Foundation
import XCTest

@testable import NodeKit

public class URLQueryInjectorNodeTests: XCTestCase {

    // MARK: - Nested

    typealias Model = RoutableRequestModel<UrlRouteProvider, Json>

    class StubNode: Node {
        func process(_ data: Model) -> Observer<Model> {
            return .emit(data: data)
        }
    }

    // MARK: - Tests

    func testDefaultNodeWorkSuccessForEmptyQuery() {

        // Arrange

        let startUrl = URL(string: "http://host.dom/path")!

        let request = Model(metadata: [:], raw: Json(), route: startUrl)

        let node = URLQueryInjectorNode(next: StubNode(), config: .init(query: [:]))

        // Act

        var result: URL!

        node.process(request).onCompleted { result = try! $0.route.url() }

        // Assert

        XCTAssertEqual(result, startUrl)
    }

    func testDefaultNodeWorkSuccessForSimpleQuery() {

        // Arrange

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)

        let query: [String : Any] = ["name": "bob", "age": 23]

        let node = URLQueryInjectorNode(next: StubNode(), config: .init(query: query))

        // Act

        var result: URL!

        node.process(request).onCompleted { result = try! $0.route.url() }

        // Assert

        let normalizedRes = result.query!.split(separator: "&").sorted()
        let normalizedExp = "age=23&name=bob".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

    func testDefaultNodeSaveUrlAndOnlyAddQuery() {

        // Arrange

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)

        let query: [String : Any] = ["name": "bob", "age": 23]

        let node = URLQueryInjectorNode(next: StubNode(), config: .init(query: query))

        // Act

        var result: URL!

        node.process(request).onCompleted { result = try! $0.route.url() }

        // Assert

        let normalizedRes = result.query!.split(separator: "&").sorted()
        let normalizedExp = "age=23&name=bob".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)

        XCTAssertEqual(result.absoluteString.replacingOccurrences(of: result.query!, with: ""), "http://host.dom/path?")
    }

    func testDefaultNodeMutateOnlyUrlParameter() {

        // Arrange

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)

        let query: [String : Any] = ["name": "bob", "age": 23]

        let node = URLQueryInjectorNode(next: StubNode(), config: .init(query: query))

        // Act

        var result: Model!

        node.process(request).onCompleted { result = $0 }

        // Assert

        XCTAssertEqual(request.metadata, result.metadata)

        XCTAssertNotEqual(try! request.route.url(), try! result.route.url())
    }

    func testDefaultNodeWorkSuccessForArrayQuery() {

        // Arrange

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)

        let query: [String : Any] = ["arr": ["a", 23, false]]

        let node = URLQueryInjectorNode(next: StubNode(), config: .init(query: query))

        // Act

        var result: URL!

        node.process(request).onCompleted { result = try! $0.route.url() }

        // Assert

        let normalizedRes = result.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "arr[]=a&arr[]=23&arr[]=0".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

    func testDefaultNodeWorkSuccessForDictQuery() {

        // Arrange

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)

        let query: [String : Any] = ["dict": ["name": "bob", "age": 23]]

        let node = URLQueryInjectorNode(next: StubNode(), config: .init(query: query))

        // Act

        var result: URL!

        node.process(request).onCompleted { result = try! $0.route.url() }

        // Assert

        let normalizedRes = result.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "dict[age]=23&dict[name]=bob".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

    func testDefaultNodeWorkSuccessForDictAndArrQuery() {

        // Arrange

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)

        let query: [String : Any] = ["dict": ["name": "bob", "age": 23], "arr": ["a", 23, false]]

        let node = URLQueryInjectorNode(next: StubNode(), config: .init(query: query))

        // Act

        var result: URL!

        node.process(request).onCompleted { result = try! $0.route.url() }

        // Assert

        let normalizedRes = result.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "dict[age]=23&dict[name]=bob&arr[]=a&arr[]=23&arr[]=0".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

    func testDefaultNodeWorkSuccessFor2DArrQuery() {

        // Arrange

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)

        let query: [String : Any] = ["arr": ["a", 23, false, ["map"]]]

        let node = URLQueryInjectorNode(next: StubNode(), config: .init(query: query))

        // Act

        var result: URL!

        node.process(request).onCompleted { result = try! $0.route.url() }

        // Assert

        let normalizedRes = result.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "arr[]=a&arr[]=23&arr[]=0&arr[][]=map".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

}
