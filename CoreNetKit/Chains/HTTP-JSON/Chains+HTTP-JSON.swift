//
//  Chains+HTTP-JSON.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 28/01/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

extension Chains {

    public static func olddefaultChain<Input, Output>(params: TransportUrlParameters) -> Node<Input, Output>
        where Input: DTOConvertible, Output: DTOConvertible,
        Input.DTO.Raw == Json, Output.DTO.Raw == Json {

            let requestSenderNode = RequestSenderNode(rawResponseProcessor: ServiceChain.urlResponseProcessingLayerChain())
            let requestCreatorNode = RequestCreatorNode(next: requestSenderNode)
            let serviceErrorMapperNode = TechnicaErrorMapperNode(next: requestCreatorNode)
            let transportNode = TransportNode(parameters: params, next: serviceErrorMapperNode)
            let dtoConverter = DTOMapperNode<Input.DTO, Output.DTO>(next: transportNode)
            return ModelInputNode<Input, Output>(next: dtoConverter)
    }

    public static func simpleModelFlowChain<Input, Output>(params: TransportUrlParameters) -> Node<Input, Output>
        where Input: RawMappable, Output: DTOConvertible,
        Input.Raw == Json, Output.DTO.Raw == Json {

            let requestSenderNode = RequestSenderNode(rawResponseProcessor: ServiceChain.urlResponseProcessingLayerChain())
            let requestCreatorNode = RequestCreatorNode(next: requestSenderNode)
            let serviceErrorMapperNode = TechnicaErrorMapperNode(next: requestCreatorNode)
            let transportNode = TransportNode(parameters: params, next: serviceErrorMapperNode)
            let dtoConverter = DTOMapperNode<Input, Output.DTO>(next: transportNode)
            return SimpleModelInputNode<Input, Output>(next: dtoConverter)
    }


    public static func defaultChain<Input, Output>(method: Method,
                                                   route: UrlRouteProvider,
                                                   metadata: [String: String] = [:],
                                                   encoding: ParametersEncoding = .json) -> Node<Input, Output>
        where Input: DTOConvertible, Output: DTOConvertible,
        Input.DTO.Raw == Json, Output.DTO.Raw == Json {

        let requestSenderNode = RequestSenderNode(rawResponseProcessor: ServiceChain.urlResponseProcessingLayerChain())
        let requestCreatorNode = RequestCreatorNode(next: requestSenderNode)
        let serviceErrorMapperNode = TechnicaErrorMapperNode(next: requestCreatorNode)
        let urlRequestTrasformatorNode = UrlRequestTrasformatorNode(next: serviceErrorMapperNode, method: method)
        let requstEncoderNode = RequstEncoderNode(next: urlRequestTrasformatorNode, encoding: encoding)
        let requestRouterNode = RequestRouterNode(next: requstEncoderNode, route: route)
        let metadataConnectorNode = MetadataConnectorNode(next: requestRouterNode, metadata: metadata)
        let dtoConverter = DTOMapperNode<Input.DTO, Output.DTO>(next: metadataConnectorNode)
        return ModelInputNode<Input, Output>(next: dtoConverter)
    }

}
