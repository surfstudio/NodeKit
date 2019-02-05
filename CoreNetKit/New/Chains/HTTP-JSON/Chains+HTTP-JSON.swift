//
//  Chains+HTTP-JSON.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 28/01/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

extension Chains {

    public static func defaultChain<Input, Output>(params: TransportUrlParameters) -> Node<Input, Output>
        where Input: DTOConvertible, Output: DTOConvertible,
        Input.DTO.Raw == Json, Output.DTO.Raw == Json {

            let requestSenderNode = RequestSenderNode(rawResponseProcessor: ServiceChain.urlResponseProcessingLayerChain())
            let requestCreatorNode = RequestCreatorNode(next: requestSenderNode)
            let transportNode = TransportNode(parameters: params, next: requestCreatorNode)
            let dtoConverter = DTOMapperNode<Input.DTO, Output.DTO>(next: transportNode)
            return ModelInputNode<Input, Output>(next: dtoConverter)
    }

//    public static func urlChainWithUrlCache<Input, Output>(params: TransportUrlParameters) -> Node<Input, Output>
//        where Input: DTOConvertible, Output: DTOConvertible,
//        Input.DTO.Raw == Json, Output.DTO.Raw == Json {
//
//        let requestSenderNode = RequestSenderNode(rawResponseProcessor: ServiceChain.responseProcessingLayerChain())
//        let requestCreatorNode = RequestCreatorNode(next: requestSenderNode)
//        let transportNode = TransportNode(parameters: params, next: requestCreatorNode)
//        let dtoConverter = DTOMapperNode<Input.DTO, Output.DTO>(next: transportNode)
//        return ModelInputNode<Input, Output>(next: dtoConverter)
//    }

//    public static func defaultEmptyRequestChain<Output>(params: TransportUrlParameters) -> Node<Void, Output>
//        where Output: DTOConvertible, Output.DTO.Raw == RawData  {
//            let responseProcessor = ResponseProcessorNode()
//            let requestSenderNode = RequestSenderNode(rawResponseProcessor: responseProcessor)
//            let requestCreatorNode = RequestCreatorNode(next: requestSenderNode)
//            return TransportNode(parameters: params, next: requestCreatorNode)
//    }

}
