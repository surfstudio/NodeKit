import XCTest
@testable import NodeKit

public class MockerProxyConfigNodeTests: XCTestCase {


    private class StubNode: Node<RequestModel<Int>, RequestModel<Int>> {

        override func process(_ data: RequestModel<Int>) -> Observer<RequestModel<Int>> {
            return .emit(data: data)
        }
    }

    public func testNodeAddRightKeys() {

        // Arrange

        let host = "host.addr"
        let scheme = "http"

        let node = MockerProxyConfigNode(next: StubNode(), isProxyingOn: true, proxyingHost: host, proxyingScheme: scheme)

        // Act - Assert

        node.process(.init(metadata: [:], raw: 0)).onCompleted { model in
            XCTAssertEqual(model.metadata[MockerProxyConfigKey.isProxyingOn], "true")
            XCTAssertEqual(model.metadata[MockerProxyConfigKey.proxyingHost], host)
            XCTAssertEqual(model.metadata[MockerProxyConfigKey.proxyingScheme], scheme)
        }
    }

    public func testNodeDontAddKeysIfIsProxyingOnFalse() {

        // Arrange

        let host = "host.addr"
        let scheme = "http"

        let node = MockerProxyConfigNode(next: StubNode(), isProxyingOn: true, proxyingHost: host, proxyingScheme: scheme)

        // Act - Assert

        node.process(.init(metadata: [:], raw: 0)).onCompleted { model in
            XCTAssertEqual(model.metadata[MockerProxyConfigKey.isProxyingOn], "true")
            XCTAssertEqual(model.metadata[MockerProxyConfigKey.proxyingHost], host)
            XCTAssertEqual(model.metadata[MockerProxyConfigKey.proxyingScheme], scheme)
        }
    }
}
