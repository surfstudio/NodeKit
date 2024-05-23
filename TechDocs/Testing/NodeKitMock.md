# NodeKitMock

Inside the NodeKit library, there is a target called NodeKitMock. This target is necessary for writing unit tests for parts of the code that interact with NodeKit.

The NodeKit and NodeKitMock targets are separated. Therefore, if a separate target is used for unit tests in the project, there is no need to include NodeKit; you can use only NodeKitMock.

## How to use

Let's assume we have a service:

```Swift
class MyService {
    enum Endpoint: URLRouteProvider {
        case users

        func url() throws -> URL {
            return URL(string: "")!
        }
    }

    private let chainBuilder: any ChainBuilder<Endpoint>

    init(chainBuilder: any ChainBuilder<Endpoint>) {
        self.chainBuilder = chainBuilder
    }

    func getUsers() async -> NodeResult<User> {
        return await chainBuilder
            .route(.get, .users)
            .build<Void, User>()
            .process()
    }
}
```

Now let's write some tests:

```Swift
import XCTest
@testable import NodeKitMock

final class MyServiceTests: XCTestCase {
    private var chainBuilderMock: ChainBuilderMock<MyService.Endpoint>!
    private var sut: MyService!

    override func setUp() {
        super.setUp()
        chainBuilderMock = ChainBuilderMock()
        sut = MyService(chainBuilder: chainBuilderMock)
    }

    override func tearDown() {
        super.tearDown()
        chainBuilderMock = nil
        sut = nil
    }

    func testGetUser_thenRouteIsCalled() async {
        // when

        let _ = await sut.getUsers()

        // then

        XCTAssertEqual(chainBuilderMock.invokedRouteCount, 1)
        XCTAssertEqual(chainBuilderMock.invokedRouteParameter?.method, .get)
        XCTAssertEqual(chainBuilderMock.invokedRouteParameter?.route, .users)
    }

    func testGetUser_thenCorrectResultReceived() async {
        // given

        let asyncNodeMock: AsyncNodeMock<Void, User> = AsyncNodeMock()
        let expectedResult = User()

        asyncNodeMock.stubbedAsyncProccessResult = .success(expectedResult)
        chainBuilderMock.stubbedBuildWithVoidInputResult = asyncNodeMock


        // when

        let result = await sut.getUsers()

        // then

        XCTAssertEqual(chainBuilderMock.invokedBuildWithVoidInputCount, 1)
        XCTAssertEqual(result, .success(expectedResult))
    }
}
```

## Stubbing network

The NodeKit library also allows for substituting server responses using the `NetworkMock` class. For this purpose, you can inherit from `URLChainbuilder`:

```swift
import NodeKit
import NodeKitMock

public final class FakeChainBuilder<Route: URLRouteProvider>: URLChainBuilder<Route> {
    
    public init() {
        super.init(
            serviceChainProvider: URLServiceChainProvider(session: NetworkMock().urlSession)
        )
    }
}

```

Now, when building chains using `FakeChainBuilder`, all requests will be passed to `URLProtocolMock.stubbedRequestHandler`. This way, we can write server responses ourselves:

```swift
URLProtocolMock.stubbedRequestHandler = { request in
    guard 
        let url = request.url,
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
        urlComponents.host == ServerConstants.hostURL.absoluteString
    else {
        return ErrorResponseProvider.provide400Error()
    }
            
    switch urlComponents.path {
    case "/auth/login":
        return try LoginResponseProvider.provide()
    case "/pagination/list":
        return try PaginationResponseProvider.provide(for: request)
    case "/group/header":
        return try GroupResponseProvider.provideHeader()
    case "/group/body":
        return try GroupResponseProvider.provideBody()
    case "/group/footer":
        return try GroupResponseProvider.provideFooter()
    default:
        break
    }
            
    return ErrorResponseProvider.provide400Error()
}
```

For a more in-depth study, you can refer to the [Example](../Example) project, where the `MockServer` is implemented.