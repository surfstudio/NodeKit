import XCTest
@testable import NodeKit

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
    
    func testProcess_whenProxyIsOn_thenNodeAddRightKeys_andNextCalled() throws {
        // given
        
        let host = "host.addr1"
        let scheme = "http1"
        let isProxyingOn = true
        let expectedNextNodeResult = RequestModel<Int>(metadata: ["test1":"value1"], raw: 15)
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: expectedNextNodeResult)
        makeSut(isProxyingOn: isProxyingOn, proxyingHost: host, proxyingScheme: scheme)
        
        // when
        
        var nextNodeResult: RequestModel<Int>?
        sut.processLegacy(.init(metadata: [:], raw: 0)).onCompleted { value in
            nextNodeResult = value
        }
        
        // then
        
        let result = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter)
        let nextNodeUnwrappedResult = try XCTUnwrap(nextNodeResult)
        
        XCTAssertEqual(nextNodeMock.invokedProcessLegacyCount, 1)
        XCTAssertEqual(result.metadata[MockerProxyConfigKey.isProxyingOn], "\(isProxyingOn)")
        XCTAssertEqual(result.metadata[MockerProxyConfigKey.proxyingHost], host)
        XCTAssertEqual(result.metadata[MockerProxyConfigKey.proxyingScheme], scheme)
        XCTAssertEqual(nextNodeUnwrappedResult.metadata, expectedNextNodeResult.metadata)
        XCTAssertEqual(nextNodeUnwrappedResult.raw, expectedNextNodeResult.raw)
    }
    
    func testProcess_whenProxyIsOff_thenNodeAddRightKeys_andNextCalled() throws {
        // given
        
        let host = "host.addr2"
        let scheme = "http2"
        let isProxyingOn = false
        let expectedNextNodeResult = RequestModel<Int>(metadata: ["test2":"value2"], raw: 16)
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: expectedNextNodeResult)
        makeSut(isProxyingOn: isProxyingOn, proxyingHost: host, proxyingScheme: scheme)
        
        // when
        
        var nextNodeResult: RequestModel<Int>?
        sut.processLegacy(.init(metadata: [:], raw: 0)).onCompleted { value in
            nextNodeResult = value
        }
        
        // then
        
        let result = try XCTUnwrap(nextNodeMock.invokedProcessLegacyParameter)
        let nextNodeUnwrappedResult = try XCTUnwrap(nextNodeResult)
        
        XCTAssertEqual(nextNodeMock.invokedProcessLegacyCount, 1)
        XCTAssertNil(result.metadata[MockerProxyConfigKey.isProxyingOn])
        XCTAssertNil(result.metadata[MockerProxyConfigKey.proxyingHost])
        XCTAssertNil(result.metadata[MockerProxyConfigKey.proxyingScheme])
        XCTAssertEqual(nextNodeUnwrappedResult.metadata, expectedNextNodeResult.metadata)
        XCTAssertEqual(nextNodeUnwrappedResult.raw, expectedNextNodeResult.raw)
    }
    
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
