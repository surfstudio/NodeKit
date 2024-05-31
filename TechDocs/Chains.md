# Implemented chains

## URLChains

It contains out-of-the-box chains for working with URL requests.

By default, the following nodes are implemented in the chain:

1. `LoggerNode` - outputs logs
2. `ModelInputNode` - maps the response from `RawMappable` to `DTOConvertible`
3. `DTOMapperNode` - maps the response from `DTOConvertible` to `RawMappable`
4. `MetadataConnectorNode` - adds `metadata` to `RequestModel`
5. `RequestRouterNode` - adds route to request
6. `RequstEncoderNode` - adds coding to request
7. `UrlRequestTrasformatorNode` - this node constructs a specific `URL` request, transforming `metadata` into `headers`, `route` into `URL`, etc.
8. `RequestCreatorNode` - creates a network request using `URLSession`
9. `TechnicaErrorMapperNode` - maps technical errors (timeout, lack of internet connection, etc.)
10. `RequestSenderNode` - sends a request to the network
11. `ResponseProcessorNode` - handles the server response, checking whether the request was successful or not. If successful, it checks whether the response can be mapped to JSON or not
12. `ResponseHttpErrorProcessorNode` - this node handles checking whether any HTTP errors occurred (checks the code). If so, it creates an instance of `ResponseHttpErrorProcessorNodeError` and terminates the chain execution.
13. `ResponseDataPreprocessorNode` - here we check the response.
14. `ResponseDataParserNode` - obtains `JSON` from `Data`

This chain **DOES NOT** contain caching.

`build<I,O>` - a classic request. Expects data both as input and output (described above)

`build<Void, Void>` - a chain that does not expect data either as input or output

`build<I, Void>` - a chain that expects data as input but does not return data (server responds with an empty body)

`build<Void, I>` - a chain that does not expect data as input but expects data as output (a classic GET request)

`loadData<Void, Data>` - a chain that simply downloads the required file (for example, downloading a statically served file)

`loadData<I, Data>` - a chain that downloads a file and sends some data to the server (which can happen)

`build<I, O> where I.DTO.Raw = MultipartModel<[String : Data]>` - a chain that allows sending multipart requests

### Operations

`set(query: [String: Any])` - changes the URL query parameter of the request. 

`set(boolEncodingStartegy: URLQueryBoolEncodingStartegy)` - sets the strategy for parsing boolean variables into URL query parameters. Available out-of-the-box implementations: `URLQueryBoolEncodingDefaultStrategy.asInt`, `URLQueryBoolEncodingDefaultStrategy.asBool`. By default, `URLQueryBoolEncodingDefaultStrategy.asInt` is used.

`set(arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy)` - sets the strategy for parsing array keys into URL query parameters. Available out-of-the-box implementations: `URLQueryArrayKeyEncodingBracketsStrategy.brackets`, `URLQueryArrayKeyEncodingBracketsStrategy.noBrackets`. By default, `URLQueryArrayKeyEncodingBracketsStrategy.brackets` is used.

`set(dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy)` - sets the strategy for parsing dictionary keys into URL query parameters. Only `URLQueryDictionaryKeyEncodingDefaultStrategy` is available out-of-the-box.

`set(metadata: [String: String])` - sets the request headers that are added during the construction stage in the request (MetadataProviderNode). By default, the dictionary is empty.

`route(_ method: Method, _ route: Route)` - sets the HTTP method and URL for the request.

`encode(as encoding: ParametersEncoding)` - sets the encoding for the request. By default, `.json` is used.

`add(provider: MetadataProvider)` - adds a header provider to the request. These providers will be called immediately before sending the request.

`log(exclude: [String])` - allows excluding certain specific logs by their ID. The node name is used as the ID for the log. [More](Log/Log.md) details. 