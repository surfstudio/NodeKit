//
//  JsonNetworkReqestSenderNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

open class ReqestSenderNode: Node<RawUrlRequest, Json> {

    public typealias RawResponseProcessor = Node<DataResponse<Data>, Json>

    public var rawResponseProcessor: RawResponseProcessor

    public init(rawResponseProcessor: RawResponseProcessor) {
        self.rawResponseProcessor = rawResponseProcessor
    }

    open override func process(_ data: RawUrlRequest) -> Context<Json> {

        let context = Context<DataResponse<Data>>()

        data.dataRequest.responseData(queue: DispatchQueue.global(qos: .userInitiated)) { (response) in
            context.emit(data: response)
        }

        return context.flatMap { self.rawResponseProcessor.process($0)}
    }
}
