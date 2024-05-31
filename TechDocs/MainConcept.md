# The library's operational principle

The library functions on the principle of chaining operations on data. 
Each operation is encapsulated within a node represented by `AsyncNode<Input, Output>`.

- `Input`: The data type received by a node.
- `Output`: The data type returned by a node.

Every node is required to implement the `process(_ data: Input, logContext: LoggingContextProtocol)` where `data` represents the input data, and `logContext` represents the log storage object. You can read more about logging [here]("Log/Log.md"). 

When creating custom nodes, it is recommended to pass `logContext` further along the chain; otherwise, a new `LoggingContext` will be created, and subsequent logs will be ignored when outputting to the console.

It's essential to note that the process method operates asynchronously, and the thread in which it executes is not predetermined. 
For more details read Swift Concurrency documentation.
If it's required for the method to execute only in the main thread, the @MainActor attribute must be added to the method.

```Swift
@MainActor
func process(_ data: Input, logContext: LoggingContextProtocol) async -> NodeResult<Output> {

}
```

Let's consider an example - using the chain we created, we'll transform a string containing the ID of an entity into an object with that ID.

```Swift
// This is the data structure we want to obtain in the end.
struct User {
    let id: String
    let name: String
    let photo: String
}
```

Let's assume we have a database containing information about this user.
To retrieve it, we need to write a query to the database. Let's do this inside a node.
Since we want to retrieve a user by a string `id` - `Input == String`, `Output == User`.
It is not necessary to write associated types in the class declaration if we specify them in the `process` method.

```Swift
class UserReaderNode: AsyncNode {
    let dbContext = DBContext.shared

    func process(_ data: String, logContext: LoggingContextProtocol) -> NodeResult<User> {
        return await .withMappedExceptions {
            return try debContext.execute("SELECT user from user_table WHERE ID == \(data)") 
        }
    }
}

func getUser(by id: String) async -> NodeResult<User> {
    return await UserReaderNode().process(id)
}
```

We used here static `withMappedExceptions` method. It allowed us to map all exceptions to `Failure` of `NodeResult`.
You can find more details about this and other methods of NodeResult [here](../docs/Extensions/NodeResult.html).

What if we want to map database errors to some custom errors?
Let's write a node for this.

```Swift
enum ReadError: Error {
    case notFound
    case cantConnect
    case badRequest
    case undefined
}

class ErrorMapperNode: AsyncNode {
    let next = UserReaderNode()

    func process(_ data: String, logContext: LoggingContextProtocol) async -> NodeResult<User> {
        return await next.process(data, logContext: logContext).mapError { error in
            switch (error as NSError)?.statusCode {
                case 100:
                    return ReadError.notFound
                case 101:
                    return ReadError.cantConect
                case 102:
                    return ReadError.badRequest
                default:
                    return ReadError.undefind
            }
        }
    }
}

```
