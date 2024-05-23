# Logging

Out of the box, the library allows logging any operation performed by a node.

## How logging works

The protocol [LoggingContextProtocol](https://surfstudio.github.io/NodeKit/Protocols/LoggingContextProtocol.html), responsible for log storage, is implemented in the actor [LoggingContext](https://surfstudio.github.io/NodeKit/Actors/LoggingContext.html).

`LoggingContext` is created when the `process(_ data: Input)` method of the chain is called and is passed to all nodes in the `process(_ data: Input, logContext: LoggingContextProtocol)` method. Thus, each node has the ability to work with the same `LoggingContext`.

`LoggingContextProtocol` stores objects of [Logable](https://surfstudio.github.io/NodeKit/Protocols/Logable.html) protocol , implemented in the structure [Log](https://surfstudio.github.io/NodeKit/Structs/Log.html). 

To add a new log, you need to create a `Logable` object and pass it to `LoggingContextProtocol` using the `add` method.

The log itself represents a linked list.

![All text](log_nodes_tree.svg)

This allows us to output logs in the correct order.

![All text](log_chaining.svg)

## Logging Output

The [LoggerNode](https://surfstudio.github.io/NodeKit/Classes/LoggerNode.html) is responsible for logging output to the screen.

It is placed at the very beginning of the chain and outputs the message only after the entire chain has finished its work.

This node has a log filtering mode.

It is based on the `id` field of `Logable`. By default, it is equal to the name of the node that created the log. By default, the filter is empty, and all messages are output to the console. To exclude a specific log, you can add the node to the filter, and you can obtain the node's name like this: `CustomNode.objectName`.

By default, logs are output in the following format:
```
<<<===\(NodeName)===>>>

log message separated by \r\n and \t

```

Custom formatting for custom logs is possible according to personal preferences.

You can configure logging in the `URLChainsBuilder`. More details about this can be found [here](../Chains.md).

## Example

Let's consider an example of logging.

```Swift

func process(_ data: Input, logContext: LoggingContextProtocol) async -> NodeResult<Output> {
    var log = Log(logViewObjectName, id: objectName)

    // some operation with data

    log += "oparetion result"

    logContext.add(log)

    return await next.process(data)
}

```

Here, at the beginning, we create a log object, initializing it with the message `<<<===\(self.objectName)===>>>` and passing the name of this node as its id.

Then, we add a message about the data operation, and finally, we write the log.
