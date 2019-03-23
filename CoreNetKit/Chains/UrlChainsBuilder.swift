//
//  Chains.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 28/01/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Реулизует набор цепочек для отправки URL запросов.
open class UrlChainsBuilder {

    /// Конструктор для создания сервисных цепочек.
    public var serviceChain: UrlServiceChainBuilder

    /// Инициаллизирует объект.
    ///
    /// - Parameter serviceChain: Конструктор для создания сервисных цепочек.
    public init(serviceChain: UrlServiceChainBuilder = UrlServiceChainBuilder()) {
        self.serviceChain = serviceChain
    }

    /// Создает цепочку узлов, описывающих слой построения запроса.
    ///
    /// - Parameter config: Конфигурация для запроса
    open func requestBuildingChain(with config: UrlChainConfigModel) ->  Node<Json, Json> {
        let transportChain = self.serviceChain.requestTrasportChain()
        let urlRequestTrasformatorNode = UrlRequestTrasformatorNode(next: transportChain, method: config.method)
        let requstEncoderNode = RequstEncoderNode(next: urlRequestTrasformatorNode, encoding: config.encoding)
        let requestRouterNode = RequestRouterNode(next: requstEncoderNode, route: config.route)
        return MetadataConnectorNode(next: requestRouterNode, metadata: config.metadata)
    }

    /// Создает цепочку для отправки DTO моделей данных.
    ///
    /// - Parameter config: Конфигурация для запроса.
    open func defaultInput<Input, Output>(with config: UrlChainConfigModel) -> Node<Input, Output>
        where Input: DTOConvertible, Output: DTOConvertible,
        Input.DTO.Raw == Json, Output.DTO.Raw == Json {
            let buildingChain = self.requestBuildingChain(with: config)
            let dtoConverter = DTOMapperNode<Input.DTO, Output.DTO>(next: buildingChain)
            return ModelInputNode<Input, Output>(next: dtoConverter)
    }

    /// Создает цепочку по-умолчанию. Подразумеается работа с DTO-моделями.
    ///
    /// - Parameter config: Конфигурация для запроса.
    open func `default`<Input, Output>(with config: UrlChainConfigModel) -> Node<Input, Output>
        where Input: DTOConvertible, Output: DTOConvertible,
        Input.DTO.Raw == Json, Output.DTO.Raw == Json {
            let input: Node<Input, Output> = self.defaultInput(with: config)
            return ChainConfiguratorNode<Input, Output>(next: input)
    }

    /// Создает обычную цепочку, только в качестве входных данных принимает `Void`
    ///
    /// - Parameter config: Конфигурация для запроса.
    open func `default`<Output>(with config: UrlChainConfigModel) -> Node<Void, Output>
        where Output: DTOConvertible, Output.DTO.Raw == Json {
            let input: Node<Json, Output> = self.defaultInput(with: config)
            let configNode = ChainConfiguratorNode<Json, Output>(next: input)
            return VoidInputNode(next: configNode)
    }
}
