@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class MockerProxyConfigNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<RequestModel<Int>, RequestModel<Int>>!
    private var logContextMock: LoggingContextMock!
    
    // MARK: - Sut
    
    private var sut: MockerProxyConfigNode<Int, RequestModel<Int>>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock<RequestModel<Int>, RequestModel<Int>>()
        logContextMock = LoggingContextMock()
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_whenProxyIsOn_thenNodeAddRightKeys_andNextCalled() async throws {
        // given
        
        let host = "host.addr3"
        let scheme = "http3"
        let isProxyingOn = true
        let expectedNextNodeResult = RequestModel<Int>(metadata: ["test3":"value3"], raw: 17)
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedNextNodeResult)
        makeSut(isProxyingOn: isProxyingOn, proxyingHost: host, proxyingScheme: scheme)
        
        // when

        let nextNodeResult = await sut.process(.init(metadata: [:], raw: 0), logContext: logContextMock)
        
        // then
        
        let result = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(result.metadata[MockerProxyConfigKey.isProxyingOn], "\(isProxyingOn)")
        XCTAssertEqual(result.metadata[MockerProxyConfigKey.proxyingHost], host)
        XCTAssertEqual(result.metadata[MockerProxyConfigKey.proxyingScheme], scheme)
        XCTAssertEqual(try nextNodeResult.get().metadata, expectedNextNodeResult.metadata)
        XCTAssertEqual(try nextNodeResult.get().raw, expectedNextNodeResult.raw)
    }
    
    func testAsyncProcess_whenProxyIsOff_thenNodeAddRightKeys_andNextCalled() async throws {
        // given
        
        let host = "host.addr4"
        let scheme = "http4"
        let isProxyingOn = false
        let expectedNextNodeResult = RequestModel<Int>(metadata: ["test4":"value4"], raw: 18)
        
        nextNodeMock.stubbedAsyncProccessResult = .success(expectedNextNodeResult)
        makeSut(isProxyingOn: isProxyingOn, proxyingHost: host, proxyingScheme: scheme)
        
        // when

        let nextNodeResult = await sut.process(.init(metadata: [:], raw: 0), logContext: logContextMock)
        
        // then
        
        let result = try XCTUnwrap(nextNodeMock.invokedAsyncProcessParameters?.data)
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertNil(result.metadata[MockerProxyConfigKey.isProxyingOn])
        XCTAssertNil(result.metadata[MockerProxyConfigKey.proxyingHost])
        XCTAssertNil(result.metadata[MockerProxyConfigKey.proxyingScheme])
        XCTAssertEqual(try nextNodeResult.get().metadata, expectedNextNodeResult.metadata)
        XCTAssertEqual(try nextNodeResult.get().raw, expectedNextNodeResult.raw)
    }
    
    private func makeSut(isProxyingOn: Bool, proxyingHost: String, proxyingScheme: String) {
        sut = MockerProxyConfigNode(next: nextNodeMock, isProxyingOn: isProxyingOn, proxyingHost: proxyingHost, proxyingScheme: proxyingScheme)
    }
}