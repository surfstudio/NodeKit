//
//  ResponseDataParserNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public enum ResponseDataParserNodeError: Error {
    case cantDerializeJson
    case cantCastDesirializedDataToJson
}

open class ResponseDataParserNode: Node<UrlDataResponse, Json> {

    public typealias NextProcessorNode = Node<UrlNetworkResponse, Void>

    public var next: NextProcessorNode?

    public init(next: NextProcessorNode? = nil) {
        self.next = next
    }

    open override func process(_ data: UrlDataResponse) -> Context<Json> {

        let context = Context<Json>()
        var json = Json()

        do {
            json = try self.json(from: data)
        } catch {
            context.emit(error: error)
            return context
        }

        guard let nextNode = next else {
            return context.emit(data: json)
        }

        let networkResponse = UrlNetworkResponse(urlResponse: data.response,
                                                urlRequest: data.request,
                                                data: data.data,
                                                code: data.response.statusCode,
                                                json: json)

        return nextNode.process(networkResponse).map { json }
    }

    open func json(from responseData: UrlDataResponse) throws -> Json {

        guard let jsonObject = try? JSONSerialization.jsonObject(with: responseData.data, options: .allowFragments) else {
            throw ResponseDataParserNodeError.cantDerializeJson
        }

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
            throw ResponseDataParserNodeError.cantCastDesirializedDataToJson
        }

        return json
    }
}

