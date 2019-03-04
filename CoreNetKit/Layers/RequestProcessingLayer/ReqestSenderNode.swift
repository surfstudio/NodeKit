//
//  JsonNetworkReqestSenderNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

open class RequestSenderNode: Node<RawUrlRequest, Json>, Aborter {

    public typealias RawResponseProcessor = Node<DataResponse<Data>, Json>

    public var rawResponseProcessor: RawResponseProcessor

    private weak var request: DataRequest?
    private weak var context: Observer<DataResponse<Data>>?

    public init(rawResponseProcessor: RawResponseProcessor) {
        self.rawResponseProcessor = rawResponseProcessor
    }

    open override func process(_ data: RawUrlRequest) -> Observer<Json> {

        let context = Context<DataResponse<Data>>()

        self.context = context

        self.request = data.dataRequest.responseData(queue: DispatchQueue.global(qos: .userInitiated)) { (response) in
            context.emit(data: response)
        }

        return context.flatMap { self.rawResponseProcessor.process($0)}
    }

    open func cancel() {
        self.request?.cancel()
        self.context?.cancel()
    }
}
