# Existing nodes

Content:
  - [ModelInputNode](#modelinputnode)
  - [VoidInputNode](#voidinputnode)
  - [DTOMapperNode](#dtomappernode)
  - [RequestAssembly](#requestassembly)
  - [RequestCreatorNode](#requestcreatornode)
  - [TechnicalErrorMapperNode](#technicalerrormappernode)
  - [RequestSenderNode](#requestsendernode)
  - [ResponseProcessorNode](#responseprocessornode)
  - [ResponseDataPreprocessorNode](#responsedatapreprocessornode)
  - [ResponseHttpErrorProcessorNode](#responsehttperrorprocessornode)
  - [ResponseDataParserNode](#responsedataparsernode)
  - [AborterNode](#aborternode)
  - [AccessSafe](#accesssafe)
    - [AccessSafeNode](#accesssafenode)
    - [TokenRefresherNode](#tokenrefreshernode)
  - [HeaderInjectorNode](#headerinjectornode)

## ModelInputNode

This node has a constraint `where Input: DTOEncodable, Output: DTODecodable`. 

This means that it can only receive a model as input that can later be converted into a DTO, and it can only output a model that can be obtained from a DTO.

The next node must have the following signature: `AsyncNode<Input.DTO, Output.DTO>`.

Thus, this node converts the input model into a DTO, passes it to the next node, and then converts the response from the DTO back into the required model.

## VoidInputNode

This node resembles the `ModelInputNode` except that this node's input parameter is `Void`. It can be used to simplify the interface.

## DTOMapperNode

This node is similar to the `ModelInputNode`, with the only difference being that it converts DTO to Raw (for example, to JSON).

## RequestAssembly

These nodes are used for initial request assembly. Since the library is not tied to conventional HTTP approaches, it's not possible to explicitly specify adding headers to the request. For instance, with [gRPC](https://grpc.io), another API handles this task.

This set consists of the following nodes:

**MetadataConnectorNode** - This node's task is to abstract the process of adding headers to the request.

**RequestRouterNode** - This node's task is to abstract the process of adding a route to the endpoint.

**URLQueryInjectorNode** - This node's task is to add the URL query component to the request URL.

**RequstEncoderNode** - This node's task is to abstract the process of specifying data encoding for the request.

**UrlRequestTrasformatorNode** - This node is responsible for constructing a request for the classic HTTP approach. It receives data formed using the previous nodes and constructs a data model for creating a regular HTTP request.

## RequestCreatorNode 

This node creates an HTTP request using URLSession and passes it along for further processing.

## TechnicalErrorMapperNode

This node does nothing with the input data but transforms the output. In case the further chain ends with an error, it checks if the error is a system error (such as a timeout, lack of internet connection, etc.). If it is, it converts it into its own error and passes it along.

List of handled system errors:

1. noInternetConnection
2. timeout
3. cantConnectToHost

## RequestSenderNode

This node just sends the request and passes control to the next node. It doesn't do anything else.

## ResponseProcessorNode

This node handles the initial response processing. In case the request ends with an error (for example, no internet connection), it terminates the chain and returns the error. If the request is successful, it passes the result to the next node.

## ResponseDataPreprocessorNode

The task of this node is to continue executing the chain with an empty JSON in case the response code is 204 (no content).

## ResponseHttpErrorProcessorNode

This node maps HTTP errors. If the response code contains codes known to this node, it terminates the chain and returns an error. 

Error codes and their mapping:

```
400 -> HttpError.badRequest
401 -> HttpError.unauthorized
403 -> HttpError.forbidden
404 -> HttpError.notFound
500 -> HttpError.internalServerError
```

## ResponseDataParserNode

This node parses the response body into JSON. Different states of the JSON object are considered here. In case the response contains a JsonArray instead of a JsonObject, this node successfully parses the data as well.

## AborterNode

This node allows canceling the request. It holds a reference to the node responsible for sending the request and cancels it when necessary. 

## AccessSafe

This group of nodes is necessary for token refreshing in case it expires. The principle of operation is that if a request returns a 401 or 403 code, the request is saved, all other requests are paused, a token refresh request is sent. Then, upon success, the first request is retried, and the others are 'unfrozen'.

### AccessSafeNode

This node handles the result of executing the chain. If an access error occurs, it passes control to the `TokenRefresherNode`.

### TokenRefresherNode

This node 'freezes' requests until the token is refreshed. Then, depending on the result of the token refresh, it either returns an error or 'unfreezes' the requests.

## HeaderInjectorNode

This node can be used to inject custom headers into the request. For example, locale or any other custom headers.
