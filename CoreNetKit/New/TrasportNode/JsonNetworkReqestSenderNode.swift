//
//  JsonNetworkReqestSenderNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire


class JsonNetworkReqestSenderNode: Node<RawUrlRequest, CoreNetKitJson> {

    typealias RawResponseProcessor = Node<DataResponse<Data>, CoreNetKitJson>

    private let rawResponseProcessor: RawResponseProcessor

    init(rawResponseProcessor: RawResponseProcessor) {
        self.rawResponseProcessor = rawResponseProcessor
    }

    override func input(_ data: RawUrlRequest) -> Context<CoreNetKitJson> {

        let context = Context<DataResponse<Data>>()

        data.dataRequest.responseData(queue: DispatchQueue.global(qos: .userInitiated)) { (response) in
            context.emit(data: response)
        }

        return context.flatMap { self.rawResponseProcessor.input($0)}
    }
}
