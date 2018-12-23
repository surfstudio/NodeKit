//
//  SampleChains.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation


public func getSampleChain<Input, Output>(params: TransportUrlParameters) -> Node<Input, Output>
    where Input: DTOConvertible, Output: DTOConvertible,
            Input.DTO.Raw == Json, Output.DTO.Raw == Json {

    let responseProcessorNode = ResponseProcessorNode()
    let requestSenderNode = ReqestSenderNode(rawResponseProcessor: responseProcessorNode)
    let requestCreatorNode = RequestCreatorNode(next: requestSenderNode)
    let transportNode = TrasnportNode(parameters: params, next: requestCreatorNode)
    let dtoMapper = DTOMapperNode<Input.DTO, Output.DTO>(next: transportNode)
    let modelInput = ModelInputNode<Input, Output>(next: dtoMapper)
    return modelInput
}
