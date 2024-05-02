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
    
    /// Модель для конфигурирования URL-query в запросе.
    public var config: URLQueryConfigModel
    
    /// Массив провайдеров заголовков для запроса.
    /// Эти провайдеры используются перед непосредственной отправкой запроса.
    public var headersProviders: [MetadataProvider]

    /// HTTP метод, который будет использован цепочкой
    /// По-умолчанию GET
    public var method: Method

    /// Кодировка данных для запроса.
    ///
    /// По умолчанию`.json`
    public var encoding: ParametersEncoding

    /// В случае классического HTTP это Header'ы запроса.
    /// По-умолчанию пустой.
    public var metadata: [String: String]

    /// Маршрут до удаленного метода (в частном случае - URL endpoint'a)
    public var route: Route?

    
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
    
    open func requestRouterNode<Raw, Output>(
        next: some AsyncNode<RoutableRequestModel<URLRouteProvider, Raw>, Output>
    ) -> RequestRouterNode<Raw, URLRouteProvider, Output> {
        guard let route else {
            preconditionFailure("\(self.self) URLRoute is nil")
        }

        return RequestRouterNode(next: next, route: route)
    }
    
    /// Создает цепочку узлов, описывающих слой построения запроса.
    ///
    /// - Parameter config: Конфигурация для запроса
    open func metadataConnectorNode<O>(
        root: any AsyncNode<TransportURLRequest, O>
    ) -> some AsyncNode<Json, O> {
        let urlRequestEncodingNode = URLJsonRequestEncodingNode(next: root)
        let urlRequestTrasformatorNode = URLRequestTrasformatorNode(next: urlRequestEncodingNode, method: method)
        let requestEncoderNode = RequestEncoderNode(next: urlRequestTrasformatorNode, encoding: encoding)
        let queryInjector = URLQueryInjectorNode(next: requestEncoderNode, config: config)
        let requestRouterNode = requestRouterNode(next: queryInjector)
        return MetadataConnectorNode(next: requestRouterNode, metadata: metadata)
    }
    
    /// Создает цепочку узлов, описывающих слой построения запроса.
    ///
    /// - Parameter config: Конфигурация для запроса
    open func metadataConnectorNode(
        root: any AsyncNode<URLRequest, Json>
    ) -> any AsyncNode<MultipartModel<[String : Data]>, Json> {
        let creator = MultipartRequestCreatorNode(next: root)
        let transformator = MultipartURLRequestTrasformatorNode(next: creator, method: method)
        let queryInjector = URLQueryInjectorNode(next: transformator, config: config)
        let router = requestRouterNode(next: queryInjector)
        return MetadataConnectorNode(next: router, metadata: metadata)
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
    
    open func build<I: DTOEncodable, O: DTODecodable>() -> AnyAsyncNode<I, O>
    where I.DTO.Raw == Json, O.DTO.Raw == Json {
        let root = serviceChainProvider.provideRequestJsonChain(with: headersProviders)
        let connector = metadataConnectorNode(root: root)
        let dtoConverter = DTOMapperNode<I.DTO, O.DTO>(next: connector)
        let modelInputNode = ModelInputNode<I, O>(next: dtoConverter)
        return LoggerNode(next: modelInputNode, filters: logFilter)
            .eraseToAnyNode()
    }
    
    open func build<O: DTODecodable>() -> AnyAsyncNode<Void, O>
    where O.DTO.Raw == Json {
        let root = serviceChainProvider.provideRequestJsonChain(with: headersProviders)
        let metadataConnectorNode = metadataConnectorNode(root: root)
        let dtoConverter = DTOMapperNode<Json, O.DTO>(next: metadataConnectorNode)
        let modelInput = ModelInputNode<Json, O>(next: dtoConverter)
        let voidNode = VoidInputNode(next: modelInput)
        return LoggerNode(next: voidNode, filters: logFilter)
            .eraseToAnyNode()
    }
    
   open func build<I: DTOEncodable>() -> AnyAsyncNode<I, Void> where I.DTO.Raw == Json {
        let root = serviceChainProvider.provideRequestJsonChain(with: headersProviders)
        let metadataConnectorNode = metadataConnectorNode(root: root)
        let voidOutput = VoidOutputNode<I>(next: metadataConnectorNode)
        return LoggerNode(next: voidOutput, filters: logFilter)
           .eraseToAnyNode()
    }
    
    open func build() -> AnyAsyncNode<Void, Void> {
        let root = serviceChainProvider.provideRequestJsonChain(with: headersProviders)
        let metadataConnectorNode = metadataConnectorNode(root: root)
        let voidOutput = VoidIONode(next: metadataConnectorNode)
        return LoggerNode(next: voidOutput, filters: logFilter)
            .eraseToAnyNode()
    }
    
    open func build<I: DTOEncodable, O: DTODecodable>() -> AnyAsyncNode<I, O>
    where O.DTO.Raw == Json, I.DTO.Raw == MultipartModel<[String : Data]> {
        let root = serviceChainProvider.provideRequestMultipartChain()
        let metadataConnectorNode = metadataConnectorNode(root: root)
        let rawEncoder = DTOMapperNode<I.DTO,O.DTO>(next: metadataConnectorNode)
        let dtoEncoder = ModelInputNode<I, O>(next: rawEncoder)
        return LoggerNode(next: dtoEncoder, filters: logFilter)
            .eraseToAnyNode()
    }
    
    open func buildDataLoading() -> AnyAsyncNode<Void, Data> {
        let root = serviceChainProvider.provideRequestDataChain(with: headersProviders)
        let metadataConnectorNode = metadataConnectorNode(root: root)
        let voidInput = VoidInputNode(next: metadataConnectorNode)
        return LoggerNode(next: voidInput, filters: logFilter)
            .eraseToAnyNode()
    }
    
    open func buildDataLoading<I: DTOEncodable>() -> AnyAsyncNode<I, Data> where I.DTO.Raw == Json {
        let root = serviceChainProvider.provideRequestDataChain(with: headersProviders)
        let metadataConnectorNode = metadataConnectorNode(root: root)
        let rawEncoder = RawEncoderNode<I.DTO, Data>(next: metadataConnectorNode)
        let dtoEncoder = DTOEncoderNode<I, Data>(rawEncodable: rawEncoder)
        return LoggerNode(next: dtoEncoder, filters: logFilter)
            .eraseToAnyNode()
    }
}
