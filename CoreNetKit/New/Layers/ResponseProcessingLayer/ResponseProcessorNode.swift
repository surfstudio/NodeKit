//
//  RawJsonResponseProcessor.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

public enum ResponseProcessorNodeError: Error {
    case rawResponseNotHaveMetaData
}

open class ResponseProcessorNode: Node<DataResponse<Data>, Json> {

    private let next: ResponseProcessingLayerNode

    public init(next: ResponseProcessingLayerNode) {
        self.next = next
    }

    open override func process(_ data: DataResponse<Data>) -> Context<Json> {

        switch data.result {
        case .failure(let error):
            return Context<Json>().emit(error: error)
        case .success(let val):

            guard let urlResponse = data.response, let urlRequest = data.request else {
                return Context<Json>()
                    .emit(error: ResponseProcessorNodeError.rawResponseNotHaveMetaData)
            }

            let dataResponse = UrlDataResponse(request: urlRequest, response: urlResponse, data: val, timeline: data.timeline)

            return self.next.process(dataResponse)
        }
    }
}
