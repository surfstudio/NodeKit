//
//  UrlBsonChainsBuilder.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 31.03.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation
import Alamofire
import BSON

/// Реулизует набор цепочек для отправки URL запросов.
open class UrlBsonChainsBuilder<Route: UrlRouteProvider> {

    // MARK: - Properties / State

    /// Конструктор для создания сервисных цепочек.
    public var serviceChain: UrlServiceChainBuilder

    /// Модель для конфигурирования URL-query в запросе.
    public var urlQueryConfig: URLQueryConfigModel

    /// Массив провайдеров заголовков для запроса.
    /// Эти провайдеры используются перед непосредственной отправкой запроса.
    public var headersProviders: [MetadataProvider]

    /// HTTP метод, который будет использован цепочкой
    /// По-умолчанию GET
    public var method: Method

    /// В случае классического HTTP это Header'ы запроса.
    /// По-умолчанию пустой.
    public var metadata: [String: String]

    /// Маршрут до удаленного метода (в частном случае - URL endpoint'a)
    public var route: Route?

    /// Менеджер сессий
    public var session: URLSession?

    /// Массив с ID логов, которые нужно исключить из выдачи.
    public var logFilter: [String]

    // MARK: - Init

    /// Инициаллизирует объект.
    ///
    /// - Parameter serviceChain: Конструктор для создания сервисных цепочек.
    public init(serviceChain: UrlServiceChainBuilder = UrlServiceChainBuilder()) {
        self.serviceChain = serviceChain
        self.urlQueryConfig = .init(
            query: [:]
        )

        self.metadata = [:]
        self.method = .get
        self.headersProviders = []
        self.logFilter = []
    }

    // MARK: - State mutators

    // MARK: -- URLQueryConfigModel

    open func set(query: [String: Any]) -> Self {
        self.urlQueryConfig.query = query
        return self
    }

    open func set(boolEncodingStartegy: URLQueryBoolEncodingStartegy) -> Self {
        self.urlQueryConfig.boolEncodingStartegy = boolEncodingStartegy
        return self
    }

    open func set(arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy) -> Self {
        self.urlQueryConfig.arrayEncodingStrategy = arrayEncodingStrategy
        return self
    }

    open func set(dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy) -> Self {
        self.urlQueryConfig.dictEncodindStrategy = dictEncodindStrategy
        return self
    }

    open func set(boolEncodingStartegy: URLQueryBoolEncodingDefaultStartegy) -> Self {
        self.urlQueryConfig.boolEncodingStartegy = boolEncodingStartegy
        return self
    }

    open func set(arrayEncodingStrategy: URLQueryArrayKeyEncodingBracketsStartegy) -> Self {
        self.urlQueryConfig.arrayEncodingStrategy = arrayEncodingStrategy
        return self
    }

    // MARK: - Session config

    open func set(session: URLSession) -> Self {
        self.session = session
        return self
    }


    // MARK: - Request config

    open func set(metadata: [String: String]) -> Self {
        self.metadata = metadata
        return self
    }

    open func route(_ method: Method, _ route: Route) -> Self {
        self.method = method
        self.route = route
        return self
    }

    open func add(provider: MetadataProvider) -> Self {
        self.headersProviders.append(provider)
        return self
    }

    // MARK: - Infrastructure Config

    open func log(exclude: [String]) -> Self {
        self.logFilter += exclude
        return self
    }

    // MARK: - Public methods

    /// Создает цепочку узлов, описывающих слой построения запроса.
    ///
    /// - Parameter config: Конфигурация для запроса
    open func requestBuildingChain() -> Node<Bson, Bson> {
        let transportChain = self.serviceChain.requestBsonTrasportChain(providers: self.headersProviders, session: session)

        let urlRequestEncodingNode = UrlRequestEncodingNode<Bson, Bson>(next: transportChain)
        let urlRequestTrasformatorNode = UrlRequestTrasformatorNode<Bson, Bson>(next: urlRequestEncodingNode, method: self.method)
        let requstEncoderNode = RequstEncoderNode(next: urlRequestTrasformatorNode, encoding: nil)

        let queryInjector = URLQueryInjectorNode(next: requstEncoderNode, config: self.urlQueryConfig)

        let requestRouterNode = self.requestRouterNode(next: queryInjector)

        return MetadataConnectorNode(next: requestRouterNode, metadata: self.metadata)
    }

    /// Создает цепочку для отправки DTO моделей данных.
    open func defaultInput<Input, Output>() -> Node<Input, Output>
        where Input: DTOEncodable, Output: DTODecodable,
        Input.DTO.Raw == Bson, Output.DTO.Raw == Bson {
            let buildingChain = self.requestBuildingChain()
            let dtoConverter = DTOMapperNode<Input.DTO, Output.DTO>(next: buildingChain)
            return ModelInputNode(next: dtoConverter)
    }

    func supportNodes<Input, Output>() -> Node<Input, Output>
        where Input: DTOEncodable, Output: DTODecodable,
        Input.DTO.Raw == Bson, Output.DTO.Raw == Bson {
            let loadIndicator = LoadIndicatableNode<Input, Output>(next: self.defaultInput())
            return loadIndicator
    }

    open func requestRouterNode<Raw, Output>(next: Node<RoutableRequestModel<UrlRouteProvider, Raw>, Output>) -> RequestRouterNode<Raw, UrlRouteProvider, Output> {

        guard let url = self.route else {
            preconditionFailure("\(self.self) URLRoute is nil")
        }

        return .init(next: next, route: url)
    }

    /// Создает цепочку по-умолчанию. Подразумеается работа с DTO-моделями.
    open func build<Input, Output>() -> Node<Input, Output>
        where Input: DTOEncodable, Output: DTODecodable,
        Input.DTO.Raw == Bson, Output.DTO.Raw == Bson {
            let input: Node<Input, Output> = self.supportNodes()
            let config =  ChainConfiguratorNode<Input, Output>(next: input)
            return LoggerNode(next: config, filters: self.logFilter)
    }

    /// Создает обычную цепочку, только в качестве входных данных принимает `Void`
    open func build<Output>() -> Node<Void, Output>
        where Output: DTODecodable, Output.DTO.Raw == Bson {
            let input: Node<Bson, Output> = self.supportNodes()
            let configNode = ChainConfiguratorNode<Bson, Output>(next: input)
            let voidNode =  VoidBsonInputNode(next: configNode)
            return LoggerNode(next: voidNode, filters: self.logFilter)
    }

    /// Создает обычную цепочку, только в качестве выходных данных отдает `Void`
    open func build<Input>() -> Node<Input, Void>
        where Input: DTOEncodable, Input.DTO.Raw == Bson {
            let input = self.requestBuildingChain()
            let indicator = LoadIndicatableNode(next: input)
            let configNode = ChainConfiguratorNode(next: indicator)
            let voidOutput = VoidBsonOutputNode<Input>(next: configNode)
            return LoggerNode(next: voidOutput, filters: self.logFilter)
    }

    /// Создает обычную цепочку, только в качестве входных и выходных данных имеет `Void`
    open func build() -> Node<Void, Void> {
        let input = self.requestBuildingChain()
        let indicator = LoadIndicatableNode(next: input)
        let configNode = ChainConfiguratorNode(next: indicator)
        let voidOutput = VoidBsonIONode(next: configNode)
        return LoggerNode(next: voidOutput, filters: self.logFilter)
    }

}

