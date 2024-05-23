# Usage

Table of contents:
- [Creating a request](#creatingarequest)
  - [Routing](#routing)
  - [Encoding](#encoding)
- [Sending the request](#sendingtherequest)
  - [Service](#service)
  - [Response](#response)
- [How to use Combine](#howtousecombine)

Here are the main points and additional information on how to work with this library. 
The project contains an Example where several query options are written - you can look there as an interactive example.

## Creating a request <a name="creatingarequest"></a>


Sending a network request begins with describing:

1) Route - URI to the desired service
2) HTTP method - request method (GET, PUT, etc.)
3) Encoding - where to place the parameters and in what format (JSON in Body, String in Query, etc.)
4) Metadata - or request headers.

### Routing <a name="routing"></a>

To abstract the way of specifying the route (for example, in gRPC there are no explicit URLs), the route is a generic data type, however, in the case of URL requests, an UrlRouteProvider is expected.

This approach makes working with URL addresses a bit more elegant. For example:

```Swift
enum RegistrationRoute {
    case auth
    case users
    case user(String)
}

extension RegistrationRoute: UrlRouteProvider {
    func url() throws -> URL {
        let base = URL(string: "http://example.com")
        switch self {
        case .auth:
            return try base + "/user/auth"
        case .users:
            return try base + "/user/users"
        case .taskState:
            return try base + "/tasks"
        case .user(let id):
            return try base + "/user/\(id)"
        }
}
```
**It is considered good practice to organize routes by services or separate files.**

#### Good to know

For simplifying URL handling in CoreNetKit, there is an [extension](https://surfstudio.github.io/NodeKit/Extensions/Optional.html) for concatenating URL and String.

### Encoding <a name="encoding"></a>

NodeKit provides the following encoding types:
1) `json` - serializes request parameters into JSON and attaches them to the request body. It is the default encoding.
2) `formUrl` - serializes request parameters into FormUrlEncoding format and attaches them to the request body.
3) `urlQuery` - converts parameters into a string, replacing certain characters with special sequences (forms a URL-encoded string).

These parameters are located in [ParametersEncoding](https://surfstudio.github.io/Enums/ParametersEncoding.html)

## Sending the request <a name="sendingtherequest"></a>

To send the request, you need to call the chain and pass it the parameters described above. 

### Service <a name="service"></a>

As an example, let's write a service..

```Swift
class ExampleService {
    var builder: UrlChainsBuilder<RegistrationRoute> {
        return .init()
    }

    func auth(user: User) async -> NodeResult<Void> {
        return await builder
            .route(.post, .auth)
            .build()
            .process(user)
            .map { [weak self] (user: User) in 
                self?.saveToKeychain(user)
                return ()
            }
    }

    func getUser(by id: String) async -> NodeResult<User> {
        return await builder
            .route(.get, .user(id))
            .build()
            .process()
    }

    func getUsers() async -> NodeResult<[User]> {
        return await builder
            .route(.get, .users)
            .build()
            .process()
    }

    func updateState(by params:[String], descending: Bool, by map: [String: Any], max: Int, users: [User]) async -> NodeResult<Void> {
        return await builder
            .set(query: ["params": params], "desc": descending, "map": map, "max": maxCount)
            .set(boolEncodingStartegy: URLQueryBoolEncodingDefaultStartegy.asBool)
            .set(arrayEncodingStrategy: URLQueryBoolEncodingDefaultStartegy.noBrackets)
            .route(.post, RegistrationRoute.taskState)
            .build()
            .process(users) 
    }
}
```

To execute the request, we use [chains](Chains.md).

### Response response <a name="response"></a>

For working with the service, it is suggested to use `NodeResult<T>.` Where `NodeResult<T> = Result<T, Error>`.
You can view the available methods of NodeResult [here]("https://surfstudio.github.io/NodeKit/Extensions/NodeResult.html").
Let's consider how interaction with the service will look like from the presenter (or any other entity that communicates with the server).

```Swift
private let service = ExampleService()

@MainActor
func loadUsers() {
    showLoader()
    let result = await service.getUsers()
    hideLoader()
    
    switch result {
    case .success(models):
        show(users: model)
    case .failure(error):
        show(error: error)
    }
}

```

The library provides a logging system, which is described in more detail [here](Log/Log.md)

## How to use Combine <a name="howtousecombine"></a>

The NodeKit library allows you to obtain results using Combine. 
To get a Publisher, you need to call the method `nodeResultPublisher` instead of `process`.

When calling `sink` on the Publisher, a new Task will be created, inside of which the entire chain will be executed. 
To cancel the Task, just call the `cancel` method on the `AnyCancellable`.

```Swift
class ExampleService {
    var builder: UrlChainsBuilder<RegistrationRoute> {
        return .init()
    }

    func getUser(by id: String) -> AnyPublisher<NodeResult<User>, Never> {
        return await builder
            .route(.get, .user(id))
            .build()
            .nodeResultPublisher()
    }
}

let service = ExampleService()

let subscription1 = service.getUser(by: "1")
    .sink { user in // <-- New Task is created and process called
    }

let subscription2 = service.getUser(by: "2")
    .sink { user in // <-- New Task is created and process called
    }

// Cancel the first task
subscription1.cancel() 

// Cancel the second task
subscription2.cancel() 
```