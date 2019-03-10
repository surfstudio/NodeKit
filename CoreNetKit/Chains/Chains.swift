//
//  Chains.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 28/01/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Пустой класс, имеющий набор extension-ов для каждой default-ой реализации цепочек. 
open class Chains {

    public init() { }

    open func `defaultDtoConverter`<Input, Output>(with config: ChainConfigModel) -> Node<Input, Output>
        where Input: RawMappable, Output: RawMappable,
        Input.Raw == Json, Output.Raw == Json {
            let requestSenderNode = RequestSenderNode(rawResponseProcessor: ServiceChain.urlResponseProcessingLayerChain())
            let requestCreatorNode = RequestCreatorNode(next: requestSenderNode)
            let serviceErrorMapperNode = TechnicaErrorMapperNode(next: requestCreatorNode)
            let urlRequestTrasformatorNode = UrlRequestTrasformatorNode(next: serviceErrorMapperNode, method: config.method)
            let requstEncoderNode = RequstEncoderNode(next: urlRequestTrasformatorNode, encoding: config.encoding)
            let requestRouterNode = RequestRouterNode(next: requstEncoderNode, route: config.route)
            let metadataConnectorNode = MetadataConnectorNode(next: requestRouterNode, metadata: config.metadata)
            return DTOMapperNode<Input, Output>(next: metadataConnectorNode)
    }


    open func `defaultInput`<Input, Output>(with config: ChainConfigModel) -> Node<Input, Output>
        where Input: DTOConvertible, Output: DTOConvertible,
        Input.DTO.Raw == Json, Output.DTO.Raw == Json {
            let dtoConverterChain: Node<Input.DTO, Output.DTO> = self.defaultDtoConverter(with: config)
            return ModelInputNode<Input, Output>(next: dtoConverterChain)
    }

    open func `default`<Input, Output>(with config: ChainConfigModel) -> Node<Input, Output>
        where Input: DTOConvertible, Output: DTOConvertible,
        Input.DTO.Raw == Json, Output.DTO.Raw == Json {
            let input: Node<Input, Output> = self.defaultInput(with: config)
            return ChainConfiguratorNode(next: input)
    }
}
