//
//  RawJsonResponseProcessor.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

public enum BaseRawJsonResponseProcessorError: Error {
    case rawResponseNotHaveMetaData
    case cantMapToJson
}

public struct UrlNetworkResponse {
    public let urlResponse: URLResponse
    public let urlRequest: URLRequest
    public let data: Data
    public let code: Int
    public let json: Json
}

open class ResponseProcessorNode: Node<DataResponse<Data>, Json> {

    public typealias NextProcessorNode = Node<UrlNetworkResponse, Void>

    private let next: NextProcessorNode?

    public init(next: NextProcessorNode? = nil) {
        self.next = next
    }

    open override func process(_ data: DataResponse<Data>) -> Context<Json> {

        let context = Context<UrlNetworkResponse>()

        switch data.result {
        case .failure(let error):
            context.emit(error: error)
        case .success(let val):

            guard let urlResponse = data.response, let urlRequest = data.request else {
                return Context<Json>()
                    .emit(error: BaseRawJsonResponseProcessorError.rawResponseNotHaveMetaData)
            }


            if let jsonObject = try? JSONSerialization.jsonObject(with: val, options: .allowFragments) {

                let anyJson = { () -> Json? in
                    if let result = jsonObject as? [Json] {
                        return [MappingUtils.arrayJsonKey: result]
                    } else if let result = jsonObject as? Json {
                        return result
                    } else {
                        return nil
                    }
                }()

                guard let json = anyJson else {
                    context.emit(error: BaseRawJsonResponseProcessorError.cantMapToJson)
                    break
                }


                let result = UrlNetworkResponse(
                    urlResponse: urlResponse,
                    urlRequest: urlRequest,
                    data: val,
                    code: urlResponse.statusCode,
                    json: json
                )
                context.emit(data: result)
            } else {
                context.emit(error: BaseRawJsonResponseProcessorError.cantMapToJson)
            }
        }

        guard let nextNode = self.next else {
            return context.map { $0.json }
        }

        return context
            .combine { nextNode.process($0) }
            .map { $0.0.json }
    }
}
