@testable import NodeKit
@testable import NodeKitMock

import Foundation
import XCTest

final class URLQueryInjectorNodeTests: XCTestCase {
    
    // MARK: - Nested

    typealias Model = RoutableRequestModel<URLRouteProvider, Json>
    
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
    
    func testAsyncProcess_withEmptyQuery_thenStartURLReceived() async throws {
        // given

        let startURL = URL(string: "http://host.dom/path")!

        let request = Model(metadata: [:], raw: Json(), route: startURL)

        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: [:]))
        
        nextNodeMock.stubbedAsyncProccessResult = .success(request)

        // when

        _ = await sut.process(request, logContext: logContext)

        // then
        
        let url = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data.route.url)()

        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(url, startURL)
    }

    func testAsyncProcess_withSimpleQeury_thenCurrectURLReceived() async throws {
        // given

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)
        let query: [String : Any] = ["name": "bob", "age": 23]
        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedAsyncProccessResult = .success(request)

        // when

        _ = await sut.process(request, logContext: logContext)

        // then
        
        let input = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        let url = try input.route.url()
        let requestRouteURL = try request.route.url()
        let normalizedRes = url.query!.split(separator: "&").sorted()
        let normalizedExp = "age=23&name=bob".split(separator: "&").sorted()

        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(normalizedRes, normalizedExp)
        XCTAssertEqual(url.absoluteString.replacingOccurrences(of: url.query!, with: ""), "http://host.dom/path?")
        XCTAssertEqual(request.metadata, input.metadata)
        XCTAssertNotEqual(requestRouteURL, url)
    }

    func testAsyncProcess_withArrayQeury_thenCorrectURLReceived() async throws {
        // given

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)
        let query: [String : Any] = ["arr": ["a", 23, false]]
        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedAsyncProccessResult = .success(request)

        // when

        _ = await sut.process(request, logContext: logContext)

        // then
        
        let url = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data.route.url)()
        let normalizedRes = url.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "arr[]=a&arr[]=23&arr[]=0".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

    func testAsyncProcess_withDictionaryQeury_thenCorrectURLReceived() async throws {
        // given

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)
        let query: [String : Any] = ["dict": ["name": "bob", "age": 23]]
        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedAsyncProccessResult = .success(request)

        // when

        _ = await sut.process(request, logContext: logContext)

        // then
        
        let url = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data.route.url)()
        let normalizedRes = url.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "dict[age]=23&dict[name]=bob".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

    func testAsyncProcess_withArrayAndDictionaryQuery_thenCorrectURLReceived() async throws {
        // given

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)
        let query: [String : Any] = ["dict": ["name": "bob", "age": 23], "arr": ["a", 23, false]]
        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedAsyncProccessResult = .success(request)

        // when

        _ = await sut.process(request, logContext: logContext)

        // then
        
        let url = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data.route.url)()
        let normalizedRes = url.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "dict[age]=23&dict[name]=bob&arr[]=a&arr[]=23&arr[]=0".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }

    func testAsyncProcess_with2DArray_thenCorrectURLReceived() async throws {
        // given

        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)
        let query: [String : Any] = ["arr": ["a", 23, false, ["map"]]]
        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: query))
        
        nextNodeMock.stubbedAsyncProccessResult = .success(request)

        // when

        _ = await sut.process(request, logContext: logContext)

        // then
        
        let url = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data.route.url)()
        let normalizedRes = url.query!.removingPercentEncoding!.split(separator: "&").sorted()
        let normalizedExp = "arr[]=a&arr[]=23&arr[]=0&arr[][]=map".split(separator: "&").sorted()

        XCTAssertEqual(normalizedRes, normalizedExp)
    }
    
    func testAsyncProcess_withCancelTask_beforeStart_thenCancellationErrorReceived() async throws {
        // given
        
        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)
        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: [:]))
        
        nextNodeMock.stubbedAsyncProccessResult = .success(request)
        
        // when
        
        let task = Task {
            try? await Task.sleep(nanoseconds: 100 * 1000)
            return await sut.process(request, logContext: LoggingContextMock())
        }
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
    
    func testAsyncProcess_withCancelTask_afterStart_thenCancellationErrorReceived() async throws {
        // given
        
        let request = Model(metadata: [:], raw: Json(), route: URL(string: "http://host.dom/path")!)
        let sut = URLQueryInjectorNode(next: nextNodeMock, config: .init(query: [:]))
        
        nextNodeMock.stubbedAsyncProccessResult = .success(request)
        nextNodeMock.stubbedAsyncProcessRunFunction = {
            try? await Task.sleep(nanoseconds: 3 * 1000 * 1000)
        }
        
        // when
        
        let task = Task {
            await sut.process(request, logContext: LoggingContextMock())
        }
        
        try? await Task.sleep(nanoseconds: 100 * 1000)
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
}
