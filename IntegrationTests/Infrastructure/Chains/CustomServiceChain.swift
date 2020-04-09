//
//  CustomServiceChain.swift
//  IntegrationTests
//
//  Created by Vladislav Krupenko on 03.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

@testable
import NodeKit
import Alamofire

final class CustomServiceChain: UrlServiceChainBuilder {

    override func urlResponseBsonProcessingLayerChain() -> Node<NodeDataResponse, Bson> {
        let responseDataParserNode = ResponseBsonDataParserNode()
        let responseDataPreprocessorNode = ResponseBsonDataPreprocessorNode(next: responseDataParserNode)
        let responseHttpErrorProcessorNode = ResponseHttpErrorProcessorNode(next: responseDataPreprocessorNode)
        let responseCustomServerErrorProcessorNode = CustomServerErrorProcessorNode(next: responseHttpErrorProcessorNode)
        return ResponseProcessorNode(next: responseCustomServerErrorProcessorNode)
    }

}
