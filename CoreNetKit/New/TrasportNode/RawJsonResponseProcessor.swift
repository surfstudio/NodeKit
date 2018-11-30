//
//  RawJsonResponseProcessor.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

enum BaseRawJsonResponseProcessorError: Error {
    case rawResponseNotHaveMetaData
}

class RawJsonResponseProcessor: Node<DataResponse<Data>, CoreNetKitJson> {

    typealias NextProcessorNode = Node<UrlNetworkResponse, Void>

    private let next: NextProcessorNode?

    init(next: NextProcessorNode? = nil) {
        self.next = next
    }

    override func input(_ data: DataResponse<Data>) -> Context<CoreNetKitJson> {

        let context = Context<UrlNetworkResponse>()

        switch data.result {
        case .failure(let error):
            context.emit(error: error)
        case .success(let val):

            guard let urlResponse = data.response, let urlRequest = data.request else {
                return Context<CoreNetKitJson>()
                    .emit(error: BaseRawJsonResponseProcessorError.rawResponseNotHaveMetaData)
            }

            if let jsonObject = try? JSONSerialization.jsonObject(with: val, options: .allowFragments),
                let json = jsonObject as? CoreNetKitJson {
                let result = UrlNetworkResponse(
                    urlResponse: urlResponse,
                    urlRequest: urlRequest,
                    data: val,
                    code: urlResponse.statusCode,
                    json: json
                )
                context.emit(data: result)
            } else {
                context.emit(error: BaseJsonNetworkNodeError.cantMapToJson)
            }
        }

        guard let nextNode = self.next else {
            return context.map { $0.json }
        }

        return context
            .combine { nextNode.input($0) }
            .map { $0.0.json }
    }
}
