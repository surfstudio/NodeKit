import Foundation
import XCTest

@testable import NodeKit

final class URLQueryInjectorNodeTests: XCTestCase {
    
    // MARK: - Nested

    typealias Model = RoutableRequestModel<UrlRouteProvider, Json>
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<Model, Model>!
    private var logContext: LoggingContextMock!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContext = LoggingContextMock()
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContext = nil
    }

    // MARK: - Tests

    func testDefaultNodeWorkSuccessForEmptyQuery() throws {

        // Arrange

        let startUrl = URL(string: "http://host.dom/path")!

        let request = Model(metadata: [:], raw: Json(), route: startUrl)

        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: [:]))
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: request)

        // Act

        _ = sut.processLegacy(request)

        // Assert
        
        let result = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter?.route.url)
        let url = try result()

        XCTAssertEqual(url, startUrl)
    }

    func testDefaultNodeWorkSuccessForSimpleQuery() throws {

        // Arrange

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)

        let query: [String : Any] = ["name": "bob", "age": 23]

        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: request)

        // Act

        _ = sut.processLegacy(request)

        // Assert
        
        let result = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter?.route.url)
        let url = try result()

        let normalizedRes = url.query!.split(separator: "&").sorted()
        let normalizedExp = "age=23&name=bob".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

    func testDefaultNodeSaveUrlAndOnlyAddQuery() throws {

        // Arrange

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)

        let query: [String : Any] = ["name": "bob", "age": 23]

        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: request)

        // Act

        _ = sut.processLegacy(request)

        // Assert
        
        let result = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter?.route.url)
        let url = try result()

        let normalizedRes = url.query!.split(separator: "&").sorted()
        let normalizedExp = "age=23&name=bob".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)

        XCTAssertEqual(url.absoluteString.replacingOccurrences(of: url.query!, with: ""), "http://host.dom/path?")
    }

    func testDefaultNodeMutateOnlyUrlParameter() throws {

        // Arrange

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)

        let query: [String : Any] = ["name": "bob", "age": 23]

        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: request)

        // Act

        _ = sut.processLegacy(request)

        // Assert
        
        let result = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter)

        XCTAssertEqual(request.metadata, result.metadata)

        XCTAssertNotEqual(try request.route.url(), try result.route.url())
    }

    func testDefaultNodeWorkSuccessForArrayQuery() throws {

        // Arrange

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)

        let query: [String : Any] = ["arr": ["a", 23, false]]

        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: request)

        // Act

        _ = sut.processLegacy(request)

        // Assert
        
        let result = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter?.route.url)
        let url = try result()

        let normalizedRes = url.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "arr[]=a&arr[]=23&arr[]=0".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

    func testDefaultNodeWorkSuccessForDictQuery() throws {

        // Arrange

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)

        let query: [String : Any] = ["dict": ["name": "bob", "age": 23]]

        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: request)

        // Act

        _ = sut.processLegacy(request)

        // Assert
        
        let result = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter?.route.url)
        let url = try result()

        let normalizedRes = url.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "dict[age]=23&dict[name]=bob".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

    func testDefaultNodeWorkSuccessForDictAndArrQuery() throws {

        // Arrange

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)

        let query: [String : Any] = ["dict": ["name": "bob", "age": 23], "arr": ["a", 23, false]]

        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: request)

        // Act

        _ = sut.processLegacy(request)

        // Assert
        
        let result = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter?.route.url)
        let url = try result()

        let normalizedRes = url.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "dict[age]=23&dict[name]=bob&arr[]=a&arr[]=23&arr[]=0".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

    func testDefaultNodeWorkSuccessFor2DArrQuery() throws {

        // Arrange

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)

        let query: [String : Any] = ["arr": ["a", 23, false, ["map"]]]

        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: request)

        // Act

        _ = sut.processLegacy(request)

        // Assert
        
        let result = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter?.route.url)
        let url = try result()

        let normalizedRes = url.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "arr[]=a&arr[]=23&arr[]=0&arr[][]=map".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }
    
    func testAsyncProcess_withEmptyQuery_thenStartUrlReceived() async throws {
        // given

        let startUrl = URL(string: "http://host.dom/path")!

        let request = Model(metadata: [:], raw: Json(), route: startUrl)

        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: [:]))
        
        nextNodeMock.stubbedAsyncProccessResult = .success(request)

        // when

        _ = await sut.process(request, logContext: logContext)

        // then
        
        let url = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0.route.url)()

        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(url, startUrl)
    }

    func testAsyncProcess_withSimpleQeury_thenCurrectUrlReceived() async throws {
        // given

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)
        let query: [String : Any] = ["name": "bob", "age": 23]
        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedAsyncProccessResult = .success(request)

        // when

        _ = await sut.process(request, logContext: logContext)

        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0)
        let url = try input.route.url()
        let requestRouteUrl = try request.route.url()
        let normalizedRes = url.query!.split(separator: "&").sorted()
        let normalizedExp = "age=23&name=bob".split(separator: "&").sorted()

        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(normalizedRes, normalizedExp)
        XCTAssertEqual(url.absoluteString.replacingOccurrences(of: url.query!, with: ""), "http://host.dom/path?")
        XCTAssertEqual(request.metadata, input.metadata)
        XCTAssertNotEqual(requestRouteUrl, url)
    }

    func testAsyncProcess_withArrayQeury_thenCorrectUrlReceived() async throws {
        // given

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)
        let query: [String : Any] = ["arr": ["a", 23, false]]
        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedAsyncProccessResult = .success(request)

        // when

        _ = await sut.process(request, logContext: logContext)

        // then
        
        let url = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0.route.url)()
        let normalizedRes = url.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "arr[]=a&arr[]=23&arr[]=0".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

    func testAsyncProcess_withDictionaryQeury_thenCorrectUrlReceived() async throws {
        // given

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)
        let query: [String : Any] = ["dict": ["name": "bob", "age": 23]]
        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedAsyncProccessResult = .success(request)

        // when

        _ = await sut.process(request, logContext: logContext)

        // then
        
        let url = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0.route.url)()
        let normalizedRes = url.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "dict[age]=23&dict[name]=bob".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

    func testAsyncProcess_withArrayAndDictionaryQuery_thenCorrectUrlReceived() async throws {
        // given

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)
        let query: [String : Any] = ["dict": ["name": "bob", "age": 23], "arr": ["a", 23, false]]
        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedAsyncProccessResult = .success(request)

        // when

        _ = await sut.process(request, logContext: logContext)

        // then
        
        let url = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0.route.url)()
        let normalizedRes = url.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "dict[age]=23&dict[name]=bob&arr[]=a&arr[]=23&arr[]=0".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

    func testAsyncProcess_with2DArray_thenCorrectUrlReceived() async throws {
        // given

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)
        let query: [String : Any] = ["arr": ["a", 23, false, ["map"]]]
        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedAsyncProccessResult = .success(request)

        // when

        _ = await sut.process(request, logContext: logContext)

        // then
        
        let url = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.0.route.url)()
        let normalizedRes = url.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "arr[]=a&arr[]=23&arr[]=0&arr[][]=map".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }
}
