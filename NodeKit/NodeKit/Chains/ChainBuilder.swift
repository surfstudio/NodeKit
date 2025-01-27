//
//  ChainBuilder.swift
//  NodeKit
//
//  Created by Andrei Frolov on 02.05.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

public protocol ChainConfigBuilder {
    func set(query: [String: Any]) -> Self
    func set(boolEncodingStartegy: URLQueryBoolEncodingStartegy) -> Self
    func set(arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy) -> Self
    func set(dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy) -> Self
}

public protocol ChainBuilder<Route> {
    associatedtype Route: URLRouteProvider
    
    func route(_ method: Method, _ route: Route) -> Self
    func encode(as encoding: ParametersEncoding) -> Self
    func add(provider: MetadataProvider) -> Self
    func set(metadata: [String: String]) -> Self
    func set(loggingProxy: LoggingProxy) -> Self

    func build<I: DTOEncodable, O: DTODecodable>() -> AnyAsyncNode<I, O>
    where I.DTO.Raw == Json, O.DTO.Raw == Json
    
    func build<O: DTODecodable>() -> AnyAsyncNode<Void, O>
    where O.DTO.Raw == Json
    
    func build<I: DTOEncodable>() -> AnyAsyncNode<I, Void>
    where I.DTO.Raw == Json
    
    func build() -> AnyAsyncNode<Void, Void>
    
    func build<I: DTOEncodable, O: DTODecodable>() -> AnyAsyncNode<I, O>
    where O.DTO.Raw == Json, I.DTO.Raw == MultipartModel<[String : Data]>
    
    func buildDataLoading() -> AnyAsyncNode<Void, Data>

    func buildDataLoading<I: DTOEncodable>() -> AnyAsyncNode<I, Data>
    where I.DTO.Raw == Json
}

open class URLChainBuilder<Route: URLRouteProvider>: ChainConfigBuilder, ChainBuilder {

    // MARK: - Public Properties
    
    public let serviceChainProvider: ServiceChainProvider
    public let logFilter: [String]
    
    /// Model for configuring URL query of the request.
    public var config: URLQueryConfigModel
    
    /// Array of header providers for the request.
    /// These providers are used before the request is sent.
    public var headersProviders: [MetadataProvider]

    /// HTTP method to be used by the chain.
    /// By default, GET.
    public var method: Method

    /// Data encoding for the request.
    ///
    /// By default, `.json`.
    public var encoding: ParametersEncoding

    /// In the case of classic HTTP, these are the request headers.
    /// By default, empty.
    public var metadata: [String: String]

    /// Route to the remote method (specifically, the URL endpoint).
    public var route: Route?

    /// Logging proxy.
    open var loggingProxy: LoggingProxy?

    
    // MARK: - Initialization
    
    public init(
        serviceChainProvider: ServiceChainProvider = URLServiceChainProvider(),
        config: URLQueryConfigModel = URLQueryConfigModel(query: [:]),
        logFilter: [String] = []
    ) {
        self.serviceChainProvider = serviceChainProvider
        self.config = config
        self.logFilter = logFilter
        self.metadata = [:]
        self.encoding = .json
        self.method = .get
        self.headersProviders = []
    }
    
    // MARK: - Public Methods
    
    /// Adds a ``RequestRouterNode`` to the chain based on the specified Route.
    /// If the Route has not been set before calling the method, an error will be thrown.
    open func requestRouterNode<Raw, Output>(
        root: some AsyncNode<RoutableRequestModel<URLRouteProvider, Raw>, Output>
    ) -> RequestRouterNode<Raw, URLRouteProvider, Output> {
        guard let route else {
            preconditionFailure("\(self.self) URLRoute is nil")
        }

        return RequestRouterNode(next: root, route: route)
    }
    
    /// Adds to the chain a root chain of nodes describing the request construction layer.
    /// Used for requests expecting ``Json`` or Data in response.
    ///
    /// - Parameter root: The chain to which nodes will be added
    open func metadataConnectorChain<O>(
        root: any AsyncNode<TransportURLRequest, O>
    ) -> some AsyncNode<Json, O> {
        let urlRequestEncodingNode = URLJsonRequestEncodingNode(next: root)
        let urlRequestTrasformatorNode = URLRequestTrasformatorNode(next: urlRequestEncodingNode, method: method)
        let requestEncoderNode = RequestEncoderNode(next: urlRequestTrasformatorNode, encoding: encoding)
        let queryInjectorNode = URLQueryInjectorNode(next: requestEncoderNode, config: config)
        let requestRouterNode = requestRouterNode(root: queryInjectorNode)
        return MetadataConnectorNode(next: requestRouterNode, metadata: metadata)
    }
    
    /// Adds to the chain a root chain of nodes describing the request construction layer.
    /// Used for Multipart requests.
    ///
    /// - Parameter root: The chain to which nodes will be added
    open func metadataConnectorChain(
        root: any AsyncNode<MultipartURLRequest, Json>
    ) -> any AsyncNode<MultipartModel<[String : Data]>, Json> {
        let requestTransformatorNode = MultipartURLRequestTrasformatorNode(
            next: root,
            method: method
        )
        let queryInjectorNode = URLQueryInjectorNode(next: requestTransformatorNode, config: config)
        let routerNode = requestRouterNode(root: queryInjectorNode)
        return MetadataConnectorNode(next: routerNode, metadata: metadata)
    }
    
    // MARK: - ChainConfigBuilder
    
    open func set(query: [String: Any]) -> Self {
        config.query = query
        return self
    }

    open func set(boolEncodingStartegy: URLQueryBoolEncodingStartegy) -> Self {
        config.boolEncodingStartegy = boolEncodingStartegy
        return self
    }

    open func set(arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy) -> Self {
        config.arrayEncodingStrategy = arrayEncodingStrategy
        return self
    }

    open func set(dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy) -> Self {
        config.dictEncodindStrategy = dictEncodindStrategy
        return self
    }
    
    // MARK: - ChainBuilder
    
    open func route(_ method: Method, _ route: Route) -> Self {
        self.route = route
        self.method = method
        return self
    }
    
    open func encode(as encoding: ParametersEncoding) -> Self {
        self.encoding = encoding
        return self
    }
    
    open func add(provider: any MetadataProvider) -> Self {
        self.headersProviders.append(provider)
        return self
    }
    
    open func set(metadata: [String: String]) -> Self {
        self.metadata = metadata
        return self
    }

    open func set(loggingProxy: LoggingProxy) -> Self {
        self.loggingProxy = loggingProxy
        return self
    }

    open func build<I: DTOEncodable, O: DTODecodable>() -> AnyAsyncNode<I, O>
    where I.DTO.Raw == Json, O.DTO.Raw == Json {
        let requestChain = serviceChainProvider.provideRequestJsonChain(with: headersProviders)
        let metadataConnectorChain = metadataConnectorChain(root: requestChain)
        let dtoConverterNode = DTOMapperNode<I.DTO, O.DTO>(next: metadataConnectorChain)
        let modelInputNode = ModelInputNode<I, O>(next: dtoConverterNode)
        return LoggerNode(
            next: modelInputNode,
            method: method,
            route: route,
            loggingProxy: loggingProxy,
            filters: logFilter
        ).eraseToAnyNode()
    }
    
    open func build<O: DTODecodable>() -> AnyAsyncNode<Void, O>
    where O.DTO.Raw == Json {
        let requestChain = serviceChainProvider.provideRequestJsonChain(with: headersProviders)
        let metadataConnectorChain = metadataConnectorChain(root: requestChain)
        let dtoConverterNode = DTOMapperNode<Json, O.DTO>(next: metadataConnectorChain)
        let modelInputNode = ModelInputNode<Json, O>(next: dtoConverterNode)
        let voidNode = VoidInputNode(next: modelInputNode)
        return LoggerNode(
            next: voidNode,
            method: method,
            route: route,
            loggingProxy: loggingProxy,
            filters: logFilter
        ).eraseToAnyNode()
    }
    
   open func build<I: DTOEncodable>() -> AnyAsyncNode<I, Void> where I.DTO.Raw == Json {
        let requestChain = serviceChainProvider.provideRequestJsonChain(with: headersProviders)
        let metadataConnectorChain = metadataConnectorChain(root: requestChain)
        let voidOutputNode = VoidOutputNode<I>(next: metadataConnectorChain)
       return LoggerNode(
           next: voidOutputNode,
           method: method,
           route: route,
           loggingProxy: loggingProxy,
           filters: logFilter
       ).eraseToAnyNode()
    }
    
    open func build() -> AnyAsyncNode<Void, Void> {
        let requestChain = serviceChainProvider.provideRequestJsonChain(with: headersProviders)
        let metadataConnectorChain = metadataConnectorChain(root: requestChain)
        let voidOutputNode = VoidIONode(next: metadataConnectorChain)
        return LoggerNode(
            next: voidOutputNode,
            method: method,
            route: route,
            loggingProxy: loggingProxy,
            filters: logFilter
        ).eraseToAnyNode()
    }
    
    open func build<I: DTOEncodable, O: DTODecodable>() -> AnyAsyncNode<I, O>
    where O.DTO.Raw == Json, I.DTO.Raw == MultipartModel<[String : Data]> {
        let requestChain = serviceChainProvider.provideRequestMultipartChain(with: headersProviders)
        let metadataConnectorChain = metadataConnectorChain(root: requestChain)
        let rawEncoderNode = DTOMapperNode<I.DTO,O.DTO>(next: metadataConnectorChain)
        let dtoEncoderNode = ModelInputNode<I, O>(next: rawEncoderNode)
        return LoggerNode(
            next: dtoEncoderNode,
            method: method,
            route: route,
            loggingProxy: loggingProxy,
            filters: logFilter
        ).eraseToAnyNode()
    }
    
    open func buildDataLoading() -> AnyAsyncNode<Void, Data> {
        let requestChain = serviceChainProvider.provideRequestDataChain(with: headersProviders)
        let metadataConnectorChain = metadataConnectorChain(root: requestChain)
        let voidInputNode = VoidInputNode(next: metadataConnectorChain)
        return LoggerNode(
            next: voidInputNode,
            method: method,
            route: route,
            loggingProxy: loggingProxy,
            filters: logFilter
        ).eraseToAnyNode()
    }
    
    open func buildDataLoading<I: DTOEncodable>() -> AnyAsyncNode<I, Data> where I.DTO.Raw == Json {
        let requestChain = serviceChainProvider.provideRequestDataChain(with: headersProviders)
        let metadataConnectorChain = metadataConnectorChain(root: requestChain)
        let rawEncoderNode = RawEncoderNode<I.DTO, Data>(next: metadataConnectorChain)
        let dtoEncoderNode = DTOEncoderNode<I, Data>(rawEncodable: rawEncoderNode)
        return LoggerNode(
            next: dtoEncoderNode,
            method: method,
            route: route,
            loggingProxy: loggingProxy,
            filters: logFilter
        ).eraseToAnyNode()
    }
}
